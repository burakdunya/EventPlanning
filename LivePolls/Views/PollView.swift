//
//  PollView.swift
//  LivePolls
//
//  Created by Efe Koç on 09/07/23.
//

import SwiftUI

struct PollView: View {
    
    var vm: PollViewModel
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("Anket ID")
                    Text(vm.pollId)
                        .font(.caption)
                        .textSelection(.enabled)
                }
                
                HStack {
                    Text("Güncellendi")
                    Spacer()
                    if let updatedAt = vm.poll?.updatedAt {
                        Text(updatedAt, style: .time)
                    }
                }
                
                HStack {
                    Text("Toplam Oy Sayısı")
                    Spacer()
                    if let totalCount = vm.poll?.totalCount {
                        Text(String(totalCount))
                    }
                }
            }
            
            if let options = vm.poll?.options {
                Section {
                    PollChartView(options: options)
                        .frame(height: 200)
                        .padding(.vertical)
                }
                
                Section("Oy Ver") {
                    ForEach(options) { option in
                        Button(action: {
                            if vm.votedOptionIds.contains(option.id) {
                                print("Bu seçeneğe zaten oy verdiniz!")
                            } else {
                                vm.incrementOption(option)
                            }
                        }, label: {
                            HStack {
                                Text("•")
                                Text(option.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(String(option.count))
                                
                                if vm.votedOptionIds.contains(option.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        })
                        .disabled(vm.votedOptionIds.contains(option.id))
                    }
                }
            }
        }
        .navigationTitle(vm.poll?.name ?? "")
        .onAppear {
            vm.listenToPoll()
        }
    }
}

#Preview {
    NavigationStack {
        PollView(vm: .init(pollId: "22262451-09CC-4E9F-8556-616DA9A5207D"))
    }
}
