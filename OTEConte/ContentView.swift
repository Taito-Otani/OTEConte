//
//  ContentView.swift
//  OTEConte
//
//  Created by 大谷泰斗 on 2021/08/13.
//

//TODO
// 欲しい機能
//・保存機能
//・コマの連番書き出し
//・AirDrop機能
//

import SwiftUI
import PencilKit
import PDFKit

struct ContentView: View {
    @State private var showActivityView: Bool = false
    @State private var pageNums = 2
    @State private var sherePDF = URL(fileURLWithPath: "")
    var body: some View {
        List{
            ForEach(1..<pageNums, id: \.self){ _nums  in
                VStack(){
                    ConteView(nums: _nums)
                    HStack{
                        Spacer()
                        Text(" ＋ ").onTapGesture {
                            if(_nums == pageNums-1){
                                pageNums = pageNums + 1
                            }
                        }
                        Spacer()
                        Spacer()
                        Text("OT.E-Conte - NINETEEN95 STUDIO")
                        //TODO add Export PDF feature
                        Button(action: {
                            exportToPDF()
                        }) {
                            Image(systemName:"square.and.arrow.up")
                        }
                        .sheet(isPresented: self.$showActivityView) {
                            ActivityView(
                                activityItems:[sherePDF],
                                applicationActivities: nil
                            )
                        }
                    }
                }
            }
        }
    }
    
    func exportToPDF() {
        let outputFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("e-conte.pdf")
        let pageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let rootVC = UIApplication.shared.windows.first?.rootViewController
        //Render the PDF
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        DispatchQueue.main.async {
            do {
                try pdfRenderer.writePDF(to: outputFileURL, withActions: { (context) in
                    context.beginPage()
                    rootVC?.view.layer.render(in: context.cgContext)
                })
                
                sherePDF = outputFileURL
                
                self.showActivityView = true
                print("wrote file to: \(outputFileURL.path)")
            } catch {
                print("Could not create PDF file: \(error.localizedDescription)")
            }
        }
    }
}


struct ConteView: View {
    @State private var isShowing = false
    @State private var canvas = PKCanvasView()
    @State private var memoCanvas = PKCanvasView()
    var nums: Int
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text("No  \(nums)")
                Spacer()
                Spacer()
                Spacer()
                Button(action: {
                    isShowing = true
                }) {
                    Text("+ Memo")
                }.sheet(isPresented: $isShowing, content: {
                    VStack {
                        Text("Memo")
                        PenKitView(pkcView: $memoCanvas)
                    }
                    .navigationBarTitle("MemoView")
                })
                Spacer()
            }
            VStack{
                ZStack{
                    PenKitView(pkcView: $canvas)
                    VStack{
                        ForEach(1..<5) { num in
                            VStack{
                                HStack(){
                                    Spacer()
                                    Rectangle()
                                        .stroke(Color.black, lineWidth: 5)
                                        .frame(width:UIScreen.main.bounds.size.width*0.5, height: UIScreen.main.bounds.size.width*0.5*9/16)
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                }
                                
                            }.frame(height: UIScreen.main.bounds.size.height/4.75)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .padding()
    }
}


struct PenKitView:UIViewRepresentable {
    @Binding var pkcView: PKCanvasView
    typealias UIViewType = PKCanvasView
    let toolPicker = PKToolPicker()
    func makeUIView(context: Context) -> PKCanvasView {
//        let pkcView = PKCanvasView()
        pkcView.drawingPolicy = PKCanvasViewDrawingPolicy.anyInput
        toolPicker.addObserver(pkcView)
        toolPicker.setVisible(true, forFirstResponder: pkcView)
        pkcView.becomeFirstResponder()
        return pkcView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context){
//        var img = uiView.drawing.image(from: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), scale: 1)
        print("drawing")
    }
}


struct ActivityView: UIViewControllerRepresentable {
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityView>
    ) -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {
        // Nothing to do
    }
    
}
