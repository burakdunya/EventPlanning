//
//  PollViewModel.swift
//  LivePolls
//
//  Created by Efe Koç on 09/07/23.
//

import ActivityKit
import FirebaseFirestore
import Foundation
import SwiftUI
import Observation

@Observable
class PollViewModel {
    // MARK: - Properties
    let db = Firestore.firestore()
    let pollId: String
    var poll: Poll? = nil
    var activity: Activity<LivePollsWidgetAttributes>? = nil
    private(set) var votedOptionIds: Set<String> = []
    private var isVoting = false
    
    // MARK: - Initialization
    init(pollId: String, poll: Poll? = nil) {
        self.pollId = pollId
        self.poll = poll
        fetchUserVotes()
    }
    
    // MARK: - Vote Management
    private func fetchUserVotes() {
        let deviceId = DeviceIdentifier.current
        db.collection("polls/\(pollId)/votes")
            .whereField("deviceId", isEqualTo: deviceId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                self.votedOptionIds = Set(documents.compactMap { $0.data()["optionId"] as? String })
        }
    }
    
    func incrementOption(_ option: Option) {
        guard !isVoting else {
            print("İşlem devam ediyor, lütfen bekleyin...")
            return
        }
        
        guard !votedOptionIds.contains(option.id) else {
            print("Bu seçeneğe zaten oy verdiniz!")
            return
        }
        
        guard let index = poll?.options.firstIndex(where: { $0.id == option.id }) else { return }
        
        isVoting = true
        
        updatePollInFirestore(optionIndex: index, optionId: option.id)
    }
    
    private func updatePollInFirestore(optionIndex: Int, optionId: String) {
        db.document("polls/\(pollId)").updateData([
            "totalCount": FieldValue.increment(Int64(1)),
            "option\(optionIndex).count": FieldValue.increment(Int64(1)),
            "lastUpdatedOptionId": optionId,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Oy verme başarısız: \(error.localizedDescription)")
                self.isVoting = false
                return
            }
            
            self.saveUserVote(optionId: optionId)
        }
    }
    
    private func saveUserVote(optionId: String) {
        let deviceId = DeviceIdentifier.current
        let voteRef = db.collection("polls/\(pollId)/votes").document()
        
        voteRef.setData([
            "optionId": optionId,
            "deviceId": deviceId,
            "timestamp": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Kullanıcı oyu kaydedilemedi: \(error.localizedDescription)")
            } else {
                self.votedOptionIds.insert(optionId)
                print("Kullanıcı oyu başarıyla kaydedildi.")
            }
            
            self.isVoting = false
        }
    }
    
    // MARK: - Live Activity Management
    @MainActor
    func listenToPoll() {
        db.document("polls/\(pollId)")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let snapshot else { return }
                do {
                    let poll = try snapshot.data(as: Poll.self)
                    withAnimation {
                        self.poll = poll
                    }
                    self.startActivityIfNeeded()
                } catch {
                    print("Failed to fetch poll")
                }
            }
    }
    
    func startActivityIfNeeded() {
        guard let poll = self.poll,
              activity == nil,
              ActivityAuthorizationInfo().frequentPushesEnabled else { return }
        
        if let currentPollIdActivity = Activity<LivePollsWidgetAttributes>.activities.first(where: { activity in
            activity.attributes.pollId == pollId
        }) {
            self.activity = currentPollIdActivity
        } else {
            startNewActivity(for: poll)
        }
        
        setupPushTokenUpdates()
    }
    
    private func startNewActivity(for poll: Poll) {
        do {
            let activityAttributes = LivePollsWidgetAttributes(pollId: pollId)
            let activityContent = ActivityContent(
                state: poll,
                staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
            )
            
            activity = try Activity.request(
                attributes: activityAttributes,
                content: activityContent,
                pushType: .token
            )
            
            print("Requested a live activity \(String(describing: activity?.id))")
        } catch {
            print("Error requesting live activity \(error.localizedDescription)")
        }
    }
    
    private func setupPushTokenUpdates() {
        let deviceId = DeviceIdentifier.current
        
        Task { [weak self] in
            guard let self = self,
                  let activity = self.activity else { return }
            
            for try await token in activity.pushTokenUpdates {
                let tokenParts = token.map { data in String(format: "%02.2hhx", data) }
                let token = tokenParts.joined()
                print("Live activity token updated: \(token)")
                
                do {
                    try await self.db.collection("polls/\(pollId)/push_tokens")
                        .document(deviceId)
                        .setData(["token": token])
                } catch {
                    print("Failed to update token: \(error.localizedDescription)")
                }
            }
        }
    }
}
