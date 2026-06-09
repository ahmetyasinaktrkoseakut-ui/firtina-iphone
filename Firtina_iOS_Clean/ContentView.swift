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
        
        // --- BLOB REVOCATION DELAY PATCH (atDocumentStart) ---
        let revokeScriptCode = """
        if (!window.safeRevokeObjectURL) {
            window.safeRevokeObjectURL = window.URL.revokeObjectURL;
            window.URL.revokeObjectURL = function(url) {
                setTimeout(function() { window.safeRevokeObjectURL(url); }, 10000);
            };
        }
        """
        let revokeScript = WKUserScript(source: revokeScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(revokeScript)
        
        // --- IOS DOWNLOAD BRIDGE SCRIPT (atDocumentEnd) ---
        let iosDownloadBridgeScriptCode = """
        (function() {
            if (window.IosDownloadBridgeInjected) return;
            window.IosDownloadBridgeInjected = true;

            function handleBlobUrl(url, filename) {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', url, true);
                xhr.responseType = 'blob';
                xhr.onload = function() {
                    if (this.status === 200) {
                        var blob = this.response;
                        var reader = new FileReader();
                        reader.readAsDataURL(blob);
                        reader.onloadend = function() {
                            var base64data = reader.result;
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iosDownloadBridge) {
                                window.webkit.messageHandlers.iosDownloadBridge.postMessage({
                                    base64: base64data,
                                    mimeType: blob.type,
                                    filename: filename || 'downloaded_file'
                                });
                            }
                        };
                    }
                };
                xhr.send();
            }

            document.addEventListener('click', function(e) {
                var target = e.target;
                while (target && target.tagName !== 'A') {
                    target = target.parentNode;
                }
                if (target && target.tagName === 'A') {
                    var href = target.getAttribute('href');
                    var download = target.getAttribute('download');
                    if (href) {
                        if (href.startsWith('blob:')) {
                            handleBlobUrl(href, download);
                            e.preventDefault();
                        } else if (href.startsWith('data:')) {
                            var commaIdx = href.indexOf(',');
                            if (commaIdx !== -1) {
                                var base64Data = href.substring(commaIdx + 1);
                                var meta = href.substring(0, commaIdx);
                                var mime = 'image/png';
                                var mimeMatch = meta.match(/data:([^;]+)/);
                                if (mimeMatch) mime = mimeMatch[1];
                                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iosDownloadBridge) {
                                    window.webkit.messageHandlers.iosDownloadBridge.postMessage({
                                        base64: base64Data,
                                        mimeType: mime,
                                        filename: download || 'downloaded_file'
                                    });
                                }
                                e.preventDefault();
                            }
                        }
                    }
                }
            }, true);

            var originalClick = HTMLAnchorElement.prototype.click;
            HTMLAnchorElement.prototype.click = function() {
                var href = this.href;
                var download = this.getAttribute('download');
                if (href) {
                    if (href.startsWith('blob:')) {
                        handleBlobUrl(href, download);
                        return;
                    } else if (href.startsWith('data:')) {
                        var commaIdx = href.indexOf(',');
                        if (commaIdx !== -1) {
                            var base64Data = href.substring(commaIdx + 1);
                            var meta = href.substring(0, commaIdx);
                            var mime = 'image/png';
                            var mimeMatch = meta.match(/data:([^;]+)/);
                            if (mimeMatch) mime = mimeMatch[1];
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iosDownloadBridge) {
                                window.webkit.messageHandlers.iosDownloadBridge.postMessage({
                                    base64: base64Data,
                                    mimeType: mime,
                                    filename: download || 'downloaded_file'
                                });
                            }
                            return;
                        }
                    }
                }
                originalClick.apply(this, arguments);
            };

            var originalOpen = window.open;
            window.open = function(url, name, specs) {
                if (url && url.startsWith('blob:')) {
                    handleBlobUrl(url, 'downloaded_file');
                    return null;
                }
                return originalOpen.apply(this, arguments);
            };
        })();
        """
        let iosDownloadBridgeScript = WKUserScript(source: iosDownloadBridgeScriptCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(iosDownloadBridgeScript)
        
        // Register script message handler
        configuration.userContentController.add(context.coordinator, name: "iosDownloadBridge")
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

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, WKScriptMessageHandler {
        var downloadURL: URL?
        
        // Handle Javascript message calls (Blob/Base64 Downloads)
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "iosDownloadBridge",
               let body = message.body as? [String: Any],
               let base64String = body["base64"] as? String,
               let mimeType = body["mimeType"] as? String,
               let filename = body["filename"] as? String {
                
                var cleanBase64 = base64String
                if cleanBase64.contains(",") {
                    cleanBase64 = String(cleanBase64.split(separator: ",")[1])
                }
                
                guard let decodedData = Data(base64Encoded: cleanBase64, options: .ignoreUnknownCharacters) else { return }
                
                var extensionStr = ".bin"
                if mimeType.contains("png") { extensionStr = ".png" }
                else if mimeType.contains("jpeg") || mimeType.contains("jpg") { extensionStr = ".jpg" }
                else if mimeType.contains("webp") { extensionStr = ".webp" }
                else if mimeType.contains("pdf") { extensionStr = ".pdf" }
                else if mimeType.contains("gif") { extensionStr = ".gif" }
                
                let finalFilename = filename.hasSuffix(extensionStr) ? filename : (filename + extensionStr)
                let tempDir = FileManager.default.temporaryDirectory
                let fileURL = tempDir.appendingPathComponent(finalFilename)
                
                try? FileManager.default.removeItem(at: fileURL)
                do {
                    try decodedData.write(to: fileURL)
                    
                    DispatchQueue.main.async {
                        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                        
                        // iPad support
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            
                            var topVC = rootVC
                            while let presentedVC = topVC.presentedViewController {
                                topVC = presentedVC
                            }
                            
                            if let popover = activityVC.popoverPresentationController {
                                popover.sourceView = topVC.view
                                popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                                popover.permittedArrowDirections = []
                            }
                            
                            topVC.present(activityVC, animated: true, completion: nil)
                        }
                    }
                } catch {
                    print("Error writing downloaded file: \\(error)")
                }
            }
        }

        // Tüm navigasyonlara şartsız izin ver veya download ise indir
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.shouldPerformDownload {
                decisionHandler(.download)
            } else {
                decisionHandler(.allow)
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if navigationResponse.canShowMIMEType {
                decisionHandler(.allow)
            } else {
                decisionHandler(.download)
            }
        }

        func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
            download.delegate = self
        }

        func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            download.delegate = self
        }

        // target="_blank" olan linkleri zorla mevcut ekranda kendi içinde açar
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        // --- WKDownloadDelegate METHODS ---
        func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            let tempDir = FileManager.default.temporaryDirectory
            let destinationURL = tempDir.appendingPathComponent(suggestedFilename)
            self.downloadURL = destinationURL
            try? FileManager.default.removeItem(at: destinationURL)
            completionHandler(destinationURL)
        }

        func downloadDidFinish(_ download: WKDownload) {
            guard let fileURL = downloadURL else { return }
            
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                
                // iPad desteği için popover ayarlaması
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    
                    var topVC = rootVC
                    while let presentedVC = topVC.presentedViewController {
                        topVC = presentedVC
                    }
                    
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = topVC.view
                        popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    topVC.present(activityVC, animated: true, completion: nil)
                }
            }
        }

        func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
            // Hata durumunda sessizce geç
        }
    }
}
