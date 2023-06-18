//
//  ProduceFundingView.swift
//  BuddyFund
//
//  Created by Jeongwon Moon on 2023/05/23.
//
//
import SwiftUI
import UIKit

struct ProduceFundingView: View {
    let user: User
    @State private var setTitle: String = ""
    @State private var setDetail: String = ""
    @State private var setPrice: String = ""
    @State private var setBanking: String = ""
    @State private var showEmptyFieldsAlert = false
    @State private var showConfirmationAlert = false
    @State private var showSaveAlert = false
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var navigateToMypage = false
    @EnvironmentObject private var create: CreateFundViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userinfo: UserInfo

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                        entertext
                        
                        Text("사진 업로드")
                            .font(.title2)
                            .bold()
                        
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Text("이미지 선택")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 10)
                        .sheet(isPresented: $isShowingImagePicker) {
                            ImagePicker(image: $selectedImage)
                        }

                        twobutton
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .navigationTitle("펀딩 생성하기")
            }
        }
    }

    func fieldsAreNotEmpty() -> Bool {
        return !setTitle.isEmpty && !setDetail.isEmpty && !setBanking.isEmpty && !setPrice.isEmpty && Double(setPrice) != nil && Double(setPrice)! > 0
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}

private extension ProduceFundingView {
    var entertext: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("제목")
                .font(.title2)
                .bold()
            TextField("제목을 입력하세요", text: $setTitle)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))

            Text("설명")
                .font(.title2)
                .bold()
            MultilineTextView(text: $setDetail, backgroundColor: Color(uiColor: .secondarySystemBackground))
                .frame(height: 200)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))

            Text("가격")
                .font(.title2)
                .bold()
            TextField("가격을 입력하세요", text: $setPrice)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))

            Text("계좌번호")
                .font(.title2)
                .bold()
            TextField("계좌번호를 입력하세요", text: $setBanking)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
        }
    }
    
    var twobutton: some View {
        HStack {
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                showSaveAlert = true
            }) {
                Text("취소")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(8)
            }
            .alert(isPresented: $showSaveAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text("작성중인 펀딩이 취소되었습니다."),
                    dismissButton: .default(Text("확인"))
                )
            }

            Spacer()

            Button(action:{
                if fieldsAreNotEmpty() {
                    showConfirmationAlert = true
                } else {
                    showEmptyFieldsAlert = true
                }
                
            }) {
                Text("펀딩 생성하기")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(8)
            }
            .alert(isPresented: $showEmptyFieldsAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text("정보를 올바르게 입력해주세요."),
                    dismissButton: .default(Text("확인"))
                )
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text("펀딩을 생성하시겠습니까?"),
                    primaryButton: .default(Text("확인"), action: {
                        // 펀딩 생성 로직을 여기에 추가하세요. - 마이페이지로 이동
                        if let price = Int(setPrice) {
                            if let image = selectedImage {
                                create.createFund(user: user, account: setBanking, description: setDetail, price: price, title: setTitle, img: image)
                            }
                        } else {
                            print("가격 형식 에러")
                        }
                        navigateToMypage = true
                    }),
                    secondaryButton: .cancel(Text("취소"))
                )
            }
            .background(
                NavigationLink(
                    destination: Mypage(user:userinfo.user).navigationBarBackButtonHidden(true),
                    isActive: $navigateToMypage,
                    label: { EmptyView() }
                )
            )

            Spacer()
        }
        .padding(.top, 20)
    }
}

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    var backgroundColor: Color
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.backgroundColor = UIColor(backgroundColor)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextView
        
        init(_ parent: MultilineTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProduceFundingView(user: userSample)
            .environmentObject(CreateFundViewModel())
    }
}

