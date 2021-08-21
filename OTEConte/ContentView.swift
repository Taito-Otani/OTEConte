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

class SaveData: ObservableObject{
    @Published var prjNums:Int{
        didSet{
            UserDefaults.standard.set(prjNums, forKey: "prjNums")
        }
    }
    
    @Published var prjName:String {
        didSet {
            UserDefaults.standard.set(prjName, forKey: "prjName")
        }
    }
    
    @Published var pageNums:Int {
        didSet {
            UserDefaults.standard.set(pageNums, forKey: "pageNums")
        }
    }
    
    @Published var cnvData:[PKCanvasView]{
        didSet {
            UserDefaults.standard.set(cnvData, forKey: "cnvData")
        }
    }
    
    @Published var memoData:[PKCanvasView]{
        didSet {
            UserDefaults.standard.set(memoData, forKey: "memoData")
        }
    }
    /// 初期化処理
    init() {
        prjNums = UserDefaults.standard.object(forKey: "prjNums") as? Int ?? 1
        prjName = UserDefaults.standard.string(forKey: "prjName") ?? "project"
        pageNums = UserDefaults.standard.object(forKey: "pageNums") as? Int ?? 1
        cnvData = UserDefaults.standard.object(forKey: "cvnData") as? [PKCanvasView] ?? [PKCanvasView()]
        memoData = UserDefaults.standard.object(forKey: "memoData") as? [PKCanvasView] ?? [PKCanvasView()]
    }
}

class MyData: ObservableObject{

}

struct Project: Hashable  {
//    var id = UUID()
    var prjName:String
    var pageNums:Int
    var cnvData:[PKCanvasView]
    var memoData:[PKCanvasView]
}

struct ContentView: View {
    @ObservedObject var saveData = SaveData()
    @State private var projects = [Project(prjName: "aaa", pageNums: 1, cnvData: [PKCanvasView()], memoData: [PKCanvasView()])]
//    @State private var projects = []
    @State private var showActivityView: Bool = false
    @State private var pageNums = 2
    @State private var projectNums = 2
    @State private var sherePDF = URL(fileURLWithPath: "")
    @State private var nowView = 0;
    @State private var canvas:[PKCanvasView] = [PKCanvasView()]
    @State private var memoCanvas:[PKCanvasView] = [PKCanvasView()]
    
    @Environment(\.editMode) var editmode
    
    func rowRemove(offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        saveData.prjNums = projects.count
    }

    var body: some View {
        if(nowView == 0){
            VStack{
                Text("OT.E-Conte")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                Spacer()
                Image("imgs")
                    .resizable()
                    .frame(width: 200, height: 200)
                Spacer()
                HStack{
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("BY NINETEEN95 STUDIO")
                    Spacer()
                }
                List{
                    ForEach(projects, id: \.self) { prj in
                        HStack{
                            Text(prj.prjName).onTapGesture {
                                nowView = 1
                            }
                            Spacer()
                        }
                    }.onDelete(perform: rowRemove)
                }
                VStack{
                    Spacer()
                    Text("New Project +").onTapGesture {
                        projects.append(Project(prjName: "aaa", pageNums: 1, cnvData: [PKCanvasView()], memoData: [PKCanvasView()]))
                        saveData.prjNums = projects.count
                    }
                    Spacer()
                }
            }.onAppear(){
                projects = []
                for i in 0..<saveData.prjNums {
                    projects.append(Project(prjName: saveData.prjName, pageNums: saveData.pageNums, cnvData: saveData.cnvData, memoData: saveData.memoData))
                    }
            }
            
        }else if(nowView==1){
            VStack{
                HStack{
                    Spacer()
                    Text("<").onTapGesture {
                        nowView = 0
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                List{
                    ForEach(1..<pageNums, id: \.self){ _nums  in
                        
                        VStack(){
                            ConteView(canvas: $canvas[_nums-1], memoCanvas: $memoCanvas[_nums-1], nums: _nums)
                            HStack{
                                Spacer()
                                Text(" ＋ ").onTapGesture {
                                    if(_nums == pageNums-1){
                                        canvas.append(PKCanvasView())
                                        memoCanvas.append(PKCanvasView())
                                        pageNums = pageNums + 1
                                    }
                                }
                                Spacer()
                                Spacer()
                                Text("OT.E-Conte - NINETEEN95 STUDIO")
                                //TODO add Export PDF feature
                                //                        Button(action: {
                                //                            exportToPDF()
                                //                        }) {
                                //                            Image(systemName:"square.and.arrow.up")
                                //                        }
                                //                        .sheet(isPresented: self.$showActivityView) {
                                //                            ActivityView(
                                //                                activityItems:[sherePDF],
                                //                                applicationActivities: nil
                                //                            )
                                //                        }
                            }
                        }
                    }
                }
            }.onAppear(){
                
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
    @Binding var canvas:PKCanvasView
    @Binding var memoCanvas:PKCanvasView
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
