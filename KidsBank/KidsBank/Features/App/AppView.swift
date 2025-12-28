import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [Color(red: 166/255, green: 231/255, blue: 252/255),
                             Color(red: 251/255, green: 182/255, blue: 213/255)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                    
                VStack(spacing: 0) {
                    Image("mainLogo")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    
                    if !store.children.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(store.children) { child in
                                    Button {
                                        store.send(.childCardTapped(child))
                                    } label: {
                                        ChildCardView(child: child)
                                    }
                                    .buttonStyle(.plain)
                                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1.0 : 0.6)
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.5)
                                            .blur(radius: phase.isIdentity ? 0 : 2)
                                    }
                                }
                            }
                            .padding()
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .contentMargins(60, for: .scrollContent)
                    } else {
                        Spacer()
                        VStack {
                            Text("Let's open your first child's account!")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            
                            Button {
                                store.send(.addChildTapped)
                            } label: {
                                Text("Add Child")
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(Capsule().fill(.blue))
                            }
                            .padding(.top)
                        }
                        Spacer()
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            store.send(.addChildTapped)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(Circle().fill(.blue.opacity(0.8)))
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 20)
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert($store.scope(state: \.alert, action: \.alert))
            .onAppear {
                store.send(.onAppear)
            }
        } destination: { store in
            switch store.case {
            case let .childDetail(childStore):
                ChildDetailView(store: childStore)
            }
        }
        .fullScreenCover(item: $store.scope(state: \.addChild, action: \.addChild)) { store in
            AddChildView(store: store)
        }
    }
}
