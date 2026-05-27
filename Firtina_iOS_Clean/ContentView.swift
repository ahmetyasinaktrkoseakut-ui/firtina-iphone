import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        ZStack {
            // 1. Arka plan rengi tüm ekranı kaplar (Çentik kenarlarında siyah boşluk kalmaz)
            Color(red: 15/255, green: 23/255, blue: 42/255)
                .ignoresSafeArea()

            // 2. KRİTİK ÇÖZÜM: WebView'dan .ignoresSafeArea() SİLİNDİ!
            // Artık site çentiğin altına veya en alt çizgiye girmeyecek. 
            // "Atla", "Gemini", "Oturum Aç" butonları ve "Alt Menü" %100 tıklanabilir olacak.
            WebView(fileName: "index")
        }
    }
}

struct WebView: UIViewRepresentable {
    let fileName: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // --- 3. CSS VE JS KURTARMA YAMASI ---
        let jsCode = """
        var style = document.createElement('style');
        style.innerHTML = `
            /* Sadece alt menüyü en üste alır (arama çubuğunu veya diğerlerini bozmaz) */
            .bottom-nav { z-index: 999999 !important; }
            /* Uygulama kartlarındaki açıklamaların kesilmesini önler */
            .tool-card { height: auto !important; min-height: 160px !important; padding-bottom: 15px !important; }
            .tool-desc { -webkit-line-clamp: 4 !important; max-height: none !important; }
            /* En alttaki telif/gizlilik yazısının Asistan butonunun altında kalmaması için ekstra boşluk */
            footer { padding-bottom: 140px !important; }
        `;
        document.head.appendChild(style);
        
        // İlk açılışta sayfanın aşağıdan başlama sorununu çözer, en tepeye sabitler
        window.onload = function() { setTimeout(function(){ window.scrollTo(0,0); }, 50); };
        
        // Gizlilik politikasını uygulama içinde açar
        window.openPrivacy = function() { window.location.href = "privacy.html"; };
        """
        let script = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        // ---------------------------------

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Sayfanın gereksiz esnemesini kapatır
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.bounces = false
        
        // KRİTİK: iOS'ta fiziksel geri tuşu olmadığı için, dış siteye (Gemini vb.) girildiğinde
        // parmakla ekranın solundan sağa kaydırarak uygulamaya geri dönülmesini sağlar.
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html"),
           let bundleURL = Bundle.main.resourceURL {
            // 4. GİZLİLİK POLİTİKASI ÇÖZÜMÜ
            uiView.loadFileURL(url, allowingReadAccessTo: bundleURL)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        // Tüm navigasyonlara şartsız izin ver (Linklerin çalışmasını engellemez)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        // target="_blank" olan linkleri zorla mevcut ekranda kendi içinde açar
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
