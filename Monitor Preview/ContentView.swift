//
//  ContentView.swift
//  Monitor Preview
//
//  Created by Zhang Maiyun on 2022-04-15.
//

import ScreenCaptureKit
import SwiftUI

struct ContentView: View {
    @State private var displayList: [SCDisplay] = []
    @State private var error: Optional<String> = .none
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Spacer()
                    Text(LocalizedStringKey("Display Selection")).font(.title2)
                }
                .frame(height: 35)
                Spacer()
                List {
                    /* the display id is unique */
                    ForEach($displayList, id: \.self) {
                        let disp = $0.wrappedValue;
                        NavigationLink(
                            destination: DisplayPreviewView(display: disp),
                            label: {
                                VStack {
                                    HStack {
                                        Text(displayName(display: disp))
                                        Spacer()
                                    }
                                    HStack {
                                        Text(LocalizedStringKey("\(displayProp(display: disp)) @ \(disp.displayID)"))
                                        Spacer()
                                    }
                                }
                            })
                    }
                }
                VStack {
                    Divider()
                    Button {
                        Task {
                            await refreshDisplays()
                        }
                    } label: {
                        Text(LocalizedStringKey("Refresh Displays"))
                    }
                    Spacer()
                }
                .frame(height: 35)
            }
            .frame(minWidth: 200, minHeight: 400)
        }
        .task {
            await refreshDisplays()
        }
    }
    
    /** Refresh list of displays */
    func refreshDisplays() async {
        displayList = await getDisplays()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
