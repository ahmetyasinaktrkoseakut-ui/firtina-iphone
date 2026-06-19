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
        
        // İlk açılışta sayfayı en tepeye sabitle (window.onload ezmeden event listener ile)
        window.addEventListener('load', function() {
            setTimeout(function(){ window.scrollTo(0,0); }, 50);
        });
        
        // Gizlilik politikasını uygulama içinde açar
        window.openPrivacy = function() { window.location.href = "privacy.html"; };
        """
        let script = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        
        // --- IOS DOWNLOAD BRIDGE SCRIPT (atDocumentStart) ---
        let iosDownloadBridgeScriptCode = """
        (function() {
            var getUrlPath = function(url) {
                return (url || '').split('?')[0].split('#')[0].toLowerCase();
            };

            var isImageUrl = function(url) {
                if (!url) return false;
                var fullUrl = url.toLowerCase();
                var lower = getUrlPath(url);
                if (fullUrl.indexOf('googleusercontent.com') !== -1) return true;
                if (fullUrl.indexOf('oaiusercontent.com') !== -1) return true;
                if (fullUrl.indexOf('oaidalleapiprodscus.blob.core.windows.net') !== -1) return true;
                return lower.endsWith('.png') || lower.endsWith('.jpg') ||
                       lower.endsWith('.jpeg') || lower.endsWith('.webp') || 
                       lower.endsWith('.gif') || lower.endsWith('.bmp');
            };

            var isDownloadableUrl = function(url) {
                var lower = getUrlPath(url);
                return isImageUrl(url) ||
                       lower.endsWith('.pdf') ||
                       lower.endsWith('.zip') || lower.endsWith('.rar') ||
                       lower.endsWith('.tar') || lower.endsWith('.gz') ||
                       lower.endsWith('.7z') ||
                       lower.endsWith('.mp3') || lower.endsWith('.m4a') ||
                       lower.endsWith('.aac') || lower.endsWith('.wav') ||
                       lower.endsWith('.ogg') ||
                       lower.endsWith('.mp4') || lower.endsWith('.mov') ||
                       lower.endsWith('.webm');
            };

            var getMimeFromDataUrl = function(url) {
                var match = /^data:([^;,]+)/i.exec(url || '');
                return match && match[1] ? match[1] : 'application/octet-stream';
            };

            if (window.IosDownloadBridgeInjected) return;
            window.IosDownloadBridgeInjected = true;

            // Hook createObjectURL to save blobs
            if (!window.URL.originalCreateObjectURL) {
                window.URL.originalCreateObjectURL = window.URL.createObjectURL;
                window.URL.blobMap = new Map();
                window.URL.createObjectURL = function(obj) {
                    var url = window.URL.originalCreateObjectURL(obj);
                    if (obj instanceof Blob) {
                        window.URL.blobMap.set(url, obj);
                    }
                    return url;
                };
            }

            // Hook revokeObjectURL (delay by 15s to allow download)
            if (!window.URL.originalRevokeObjectURL) {
                window.URL.originalRevokeObjectURL = window.URL.revokeObjectURL;
                window.URL.revokeObjectURL = function(url) {
                    setTimeout(function() { window.URL.originalRevokeObjectURL(url); }, 15000);
                };
            }

            window.sendBase64ToIos = function(base64data, mimeType, filename) {
                if (base64data.indexOf(',') !== -1) {
                    base64data = base64data.substring(base64data.indexOf(',') + 1);
                }
                var payload = {
                    base64: base64data,
                    mimeType: mimeType,
                    filename: filename || 'downloaded_file'
                };
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iosDownloadBridge) {
                    window.webkit.messageHandlers.iosDownloadBridge.postMessage(payload);
                } else {
                    window.parent.postMessage({
                        type: 'iosDownloadBridgeMessage',
                        data: payload
                    }, '*');
                }
            };

            window.sendUrlToIos = function(url, filename) {
                var payload = {
                    url: url,
                    filename: filename || 'downloaded_file'
                };
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iosDownloadBridge) {
                    window.webkit.messageHandlers.iosDownloadBridge.postMessage(payload);
                } else {
                    window.parent.postMessage({
                        type: 'iosDownloadBridgeMessage',
                        data: payload
                    }, '*');
                }
            };

            window.handleBlobUrl = function(url, filename) {
                if (window.URL.blobMap && window.URL.blobMap.has(url)) {
                    var blob = window.URL.blobMap.get(url);
                    var reader = new FileReader();
                    reader.readAsDataURL(blob);
                    reader.onloadend = function() {
                        window.sendBase64ToIos(reader.result, blob.type, filename);
                    };
                    return;
                }
                var xhr = new XMLHttpRequest();
                xhr.open('GET', url, true);
                xhr.responseType = 'blob';
                xhr.onload = function() {
                    if (this.status === 200) {
                        var blob = this.response;
                        var reader = new FileReader();
                        reader.readAsDataURL(blob);
                        reader.onloadend = function() {
                            window.sendBase64ToIos(reader.result, blob.type, filename);
                        };
                    }
                };
                xhr.send();
            };

            window.handleHttpUrl = function(url, filename) {
                if (url && !isImageUrl(url)) {
                    window.sendUrlToIos(url, filename);
                    return;
                }
                var xhr = new XMLHttpRequest();
                xhr.open('GET', url, true);
                xhr.responseType = 'blob';
                xhr.onload = function() {
                    if (this.status === 200) {
                        var blob = this.response;
                        var reader = new FileReader();
                        reader.readAsDataURL(blob);
                        reader.onloadend = function() {
                            window.sendBase64ToIos(reader.result, blob.type, filename);
                        };
                    } else {
                        window.sendUrlToIos(url, filename);
                    }
                };
                xhr.onerror = function() {
                    window.sendUrlToIos(url, filename);
                };
                xhr.send();
            };

            // Click listener with composedPath support for Shadow DOM
            window.document.addEventListener('click', function(e) {
                var path = e.composedPath ? e.composedPath() : [];
                var target = null;
                for (var i = 0; i < path.length; i++) {
                    if (path[i] && path[i].tagName === 'A') {
                        target = path[i];
                        break;
                    }
                }
                if (!target) {
                    target = e.target;
                    while (target && target.tagName !== 'A') {
                        target = target.parentNode;
                    }
                }
                if (target && target.tagName === 'A') {
                    var href = target.getAttribute('href') || target.href;
                    var download = target.getAttribute('download');
                    if (href) {
                        if (href.startsWith('blob:')) {
                            window.handleBlobUrl(href, download);
                            e.preventDefault();
                        } else if (href.startsWith('data:')) {
                            window.sendBase64ToIos(href, getMimeFromDataUrl(href), download);
                            e.preventDefault();
                        } else if (target.hasAttribute('download') || isDownloadableUrl(href)) {
                            window.handleHttpUrl(href, download);
                            e.preventDefault();
                        }
                    }
                }
            }, true);

            // Hook HTMLAnchorElement.prototype.click
            if (window.HTMLAnchorElement) {
                var originalClick = window.HTMLAnchorElement.prototype.click;
                window.HTMLAnchorElement.prototype.click = function() {
                    var href = this.href;
                    var download = this.getAttribute('download');
                    if (href) {
                        if (href.startsWith('blob:')) {
                            window.handleBlobUrl(href, download);
                            return;
                        } else if (href.startsWith('data:')) {
                            window.sendBase64ToIos(href, getMimeFromDataUrl(href), download);
                            return;
                        } else if (this.hasAttribute('download') || isDownloadableUrl(href)) {
                            window.handleHttpUrl(href, download);
                            return;
                        }
                    }
                    if (!this.ownerDocument.body.contains(this)) {
                        this.style.display = 'none';
                        window.document.body.appendChild(this);
                        try {
                            originalClick.apply(this, arguments);
                        } finally {
                            window.document.body.removeChild(this);
                        }
                    } else {
                        originalClick.apply(this, arguments);
                    }
                };
            }

            // Hook EventTarget.prototype.dispatchEvent
            if (window.EventTarget) {
                var originalDispatch = window.EventTarget.prototype.dispatchEvent;
                window.EventTarget.prototype.dispatchEvent = function(event) {
                    if (event && event.type === 'click' && this.tagName === 'A') {
                        var href = this.getAttribute('href') || this.href;
                        var download = this.getAttribute('download');
                        if (href) {
                            if (href.startsWith('blob:')) {
                                window.handleBlobUrl(href, download);
                                return false;
                            } else if (href.startsWith('data:')) {
                                window.sendBase64ToIos(href, getMimeFromDataUrl(href), download);
                                return false;
                            } else if (this.hasAttribute('download') || isDownloadableUrl(href)) {
                                window.handleHttpUrl(href, download);
                                return false;
                            }
                        }
                    }
                    return originalDispatch.apply(this, arguments);
                };
            }

            // Hook window.open for blobs, data URLs, and direct media links
            if (window.open) {
                var originalOpen = window.open;
                window.open = function(url, name, specs) {
                    if (url) {
                        if (url.startsWith('blob:')) {
                            window.handleBlobUrl(url, 'downloaded_file');
                            return null;
                        } else if (url.startsWith('data:')) {
                            window.sendBase64ToIos(url, getMimeFromDataUrl(url), name || 'downloaded_file');
                            return null;
                        } else if (isDownloadableUrl(url)) {
                            window.handleHttpUrl(url, 'downloaded_file');
                            return null;
                        }
                    }
                    return originalOpen.apply(this, arguments);
                };
            }

            // Listen to messages from subframes (sandboxed iframes forwarding)
            if (window.top === window.self) {
                window.addEventListener('message', function(e) {
                    if (e.data && e.data.type === 'iosDownloadBridgeMessage' && e.data.data) {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iosDownloadBridge) {
                            window.webkit.messageHandlers.iosDownloadBridge.postMessage(e.data.data);
                        }
                    }
                });
            }
        })();
        """
        let iosDownloadBridgeScript = WKUserScript(source: iosDownloadBridgeScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: false)
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
        
        // Bypasses disallowed_useragent on Google Login
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
        
        // Sayfanın gereksiz esnemesini kapatır
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.bounces = false
        
        // KRİTİK: iOS'ta fiziksel geri tuşu olmadığı için, dış siteye (Gemini vb.) girildiğinde
        // parmakla ekranın solundan sağa kaydırarak uygulamaya geri dönülmesini sağlar.
        webView.allowsBackForwardNavigationGestures = true
        
        // 4. SAYFA YÜKLEME ÇÖZÜMÜ (updateUIView'den taşındı)
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html"),
           let bundleURL = Bundle.main.resourceURL {
            webView.loadFileURL(url, allowingReadAccessTo: bundleURL)
        }
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Sayfanın sonsuz döngüde yeniden yüklenmesini önlemek için boş bırakıldı
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, WKScriptMessageHandler {
        var downloadURL: URL?
        var isPresentingShareSheet = false
        
        // Handle Javascript message calls (Blob/Base64/URL Downloads)
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "iosDownloadBridge",
               let body = message.body as? [String: Any] {
                
                if let urlString = body["url"] as? String,
                   let filename = body["filename"] as? String {
                    downloadUrlNatively(urlString: urlString, filename: filename, webView: message.webView)
                    return
                }
                
                if let base64String = body["base64"] as? String,
                   let mimeType = body["mimeType"] as? String,
                   let filename = body["filename"] as? String {
                    saveBase64AndPresent(base64String: base64String, mimeType: mimeType, filename: filename)
                    return
                }
            }
        }
        private func sanitizedFilename(_ filename: String) -> String {
            var cleaned = filename.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleaned.isEmpty {
                cleaned = "downloaded_file"
            }

            let invalidCharacters = CharacterSet(charactersIn: "/\\:?%*|\"<>")
            cleaned = cleaned
                .components(separatedBy: invalidCharacters)
                .filter { !$0.isEmpty }
                .joined(separator: "_")
                .replacingOccurrences(of: "\0", with: "")

            if cleaned.isEmpty || cleaned == "." || cleaned == ".." {
                return "downloaded_file"
            }

            return cleaned
        }

        private func extensionFromMimeType(_ mimeType: String?) -> String? {
            guard let mime = mimeType?.lowercased() else { return nil }

            if mime.contains("png") { return "png" }
            if mime.contains("jpeg") || mime.contains("jpg") { return "jpg" }
            if mime.contains("webp") { return "webp" }
            if mime.contains("gif") { return "gif" }
            if mime.contains("bmp") { return "bmp" }
            if mime.contains("heic") { return "heic" }
            if mime.contains("heif") { return "heif" }
            if mime.contains("pdf") { return "pdf" }
            if mime.contains("audio/mpeg") || mime.contains("mp3") { return "mp3" }
            if mime.contains("audio/mp4") || mime.contains("m4a") { return "m4a" }
            if mime.contains("aac") { return "aac" }
            if mime.contains("wav") { return "wav" }
            if mime.contains("ogg") { return "ogg" }
            if mime.contains("mpeg") && mime.contains("audio") { return "mp3" }
            if mime.contains("mp4") { return "mp4" }
            if mime.contains("quicktime") { return "mov" }
            if mime.contains("webm") { return "webm" }
            if mime.contains("zip") { return "zip" }
            if mime.contains("json") { return "json" }

            return nil
        }

        private func preferredFilename(requested: String, response: URLResponse?) -> String {
            let requestedName = sanitizedFilename(requested)
            let requestedExtension = (requestedName as NSString).pathExtension.lowercased()
            let disposableExtensions: Set<String> = ["bin", "tmp", "dat", "download"]

            guard let responseFilename = response?.suggestedFilename,
                  !responseFilename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return requestedName
            }

            if requestedName == "downloaded_file" || disposableExtensions.contains(requestedExtension) {
                return responseFilename
            }

            return requestedName
        }

        // Helper: Resolve final filename with correct extension, replacing generic .bin when MIME/URL is known.
        private func getFinalFilename(filename: String, mimeType: String?, urlString: String?) -> String {
            let safeFilename = sanitizedFilename(filename)
            let trustedExtensions: Set<String> = [
                "png", "jpg", "jpeg", "webp", "gif", "bmp", "heic", "heif",
                "pdf", "mp3", "m4a", "aac", "wav", "ogg",
                "mp4", "mov", "webm",
                "txt", "csv", "json", "zip",
                "doc", "docx", "xls", "xlsx", "ppt", "pptx",
                "html", "htm"
            ]
            let disposableExtensions: Set<String> = ["bin", "tmp", "dat", "download"]
            let fileExtension = (safeFilename as NSString).pathExtension.lowercased()

            // Preserve real file extensions, but not generic containers like .bin.
            if trustedExtensions.contains(fileExtension) {
                return safeFilename
            }

            var resolvedExtension = extensionFromMimeType(mimeType)

            if resolvedExtension == nil,
               let urlString = urlString,
               let url = URL(string: urlString) {
                let urlExtension = url.pathExtension.lowercased()
                if trustedExtensions.contains(urlExtension) {
                    resolvedExtension = urlExtension == "jpeg" ? "jpg" : urlExtension
                }
            }

            if resolvedExtension == nil, !fileExtension.isEmpty, !disposableExtensions.contains(fileExtension) {
                return safeFilename
            }

            let finalExtension = resolvedExtension ?? "bin"
            let baseName = fileExtension.isEmpty
                ? safeFilename
                : (safeFilename as NSString).deletingPathExtension

            return "\(baseName).\(finalExtension)"
        }

        private func downloadUrlNatively(urlString: String, filename: String, webView: WKWebView?) {
            guard let url = URL(string: urlString) else { return }

            let handleDownload = { (cookies: [HTTPCookie]) in
                var request = URLRequest(url: url)
                
                let userAgent = webView?.customUserAgent ?? "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                if let webViewUrl = webView?.url?.absoluteString {
                    request.setValue(webViewUrl, forHTTPHeaderField: "Referer")
                }
                
                request.setValue("*/*", forHTTPHeaderField: "Accept")
                
                if !cookies.isEmpty {
                    let host = url.host?.lowercased() ?? ""
                    let matchedCookies = cookies.filter { cookie in
                        var cookieDomain = cookie.domain.lowercased()
                        if cookieDomain.hasPrefix(".") {
                            cookieDomain.removeFirst()
                        }
                        return host == cookieDomain || host.hasSuffix("." + cookieDomain)
                    }
                    if !matchedCookies.isEmpty {
                        let cookieHeaders = HTTPCookie.requestHeaderFields(with: matchedCookies)
                        for (key, value) in cookieHeaders {
                            request.setValue(value, forHTTPHeaderField: key)
                        }
                    }
                }
                
                let task = URLSession.shared.downloadTask(with: request) { tempURL, response, error in
                    guard let tempURL = tempURL, error == nil else {
                        print("Error downloading native URL: \(String(describing: error))")
                        return
                    }
                    
                    let candidateFilename = self.preferredFilename(requested: filename, response: response)
                    let finalFilename = self.getFinalFilename(
                        filename: candidateFilename,
                        mimeType: response?.mimeType,
                        urlString: urlString
                    )
                    
                    let tempDir = FileManager.default.temporaryDirectory
                    let destinationURL = tempDir.appendingPathComponent(finalFilename)
                    
                    try? FileManager.default.removeItem(at: destinationURL)
                    do {
                        try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                        self.presentShareSheet(fileURL: destinationURL)
                    } catch {
                        print("Error moving downloaded file: \(error)")
                    }
                }
                task.resume()
            }
            
            if let cookieStore = webView?.configuration.websiteDataStore.httpCookieStore {
                cookieStore.getAllCookies { cookies in
                    handleDownload(cookies)
                }
            } else {
                handleDownload([])
            }
        }

        private func saveBase64AndPresent(base64String: String, mimeType: String, filename: String) {
            var cleanBase64 = base64String
            if let commaIndex = cleanBase64.firstIndex(of: ",") {
                cleanBase64 = String(cleanBase64[cleanBase64.index(after: commaIndex)...])
            }

            guard let decodedData = Data(base64Encoded: cleanBase64, options: .ignoreUnknownCharacters) else { return }

            let finalFilename = getFinalFilename(filename: filename, mimeType: mimeType, urlString: nil)
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(finalFilename)

            try? FileManager.default.removeItem(at: fileURL)
            do {
                try decodedData.write(to: fileURL)
                self.presentShareSheet(fileURL: fileURL)
            } catch {
                print("Error writing downloaded base64 file: \(error)")
            }
        }

        private func presentShareSheet(fileURL: URL) {
            DispatchQueue.main.async {
                if self.isPresentingShareSheet {
                    print("Warning: Share sheet presentation is already in progress, ignoring duplicate request.")
                    return
                }

                guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                      let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
                      let rootVC = keyWindow.rootViewController else {
                    print("Error: Could not find key window root VC")
                    return
                }
                
                var topVC = rootVC
                while true {
                    if let presented = topVC.presentedViewController {
                        topVC = presented
                    } else if let navigation = topVC as? UINavigationController, let visible = navigation.visibleViewController {
                        topVC = visible
                    } else if let tab = topVC as? UITabBarController, let selected = tab.selectedViewController {
                        topVC = selected
                    } else if let child = topVC.children.last {
                        topVC = child
                    } else {
                        break
                    }
                }
                
                // CRITICAL SAFETY CHECK: Prevent double presentation crashes
                if topVC is UIActivityViewController {
                    print("Warning: UIActivityViewController is already presented, ignoring duplicate request.")
                    return
                }
                
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                activityVC.completionWithItemsHandler = { _, _, _, _ in
                    DispatchQueue.main.async {
                        self.isPresentingShareSheet = false
                    }
                }
                
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = topVC.view
                    popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                self.isPresentingShareSheet = true
                topVC.present(activityVC, animated: true, completion: nil)
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
            if let mimeType = navigationResponse.response.mimeType?.lowercased() {
                let isMedia = mimeType.hasPrefix("image/") ||
                              mimeType.hasPrefix("audio/") ||
                              mimeType.hasPrefix("video/") ||
                              mimeType == "application/pdf" ||
                              mimeType == "application/octet-stream"
                
                let isWebPage = mimeType.contains("html") ||
                                mimeType.contains("javascript") ||
                                mimeType.contains("text/css")
                
                if isMedia && !isWebPage {
                    decisionHandler(.download)
                    return
                }
            }

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
            let finalFilename = getFinalFilename(
                filename: suggestedFilename,
                mimeType: response.mimeType,
                urlString: response.url?.absoluteString
            )
            let destinationURL = tempDir.appendingPathComponent(finalFilename)
            self.downloadURL = destinationURL
            try? FileManager.default.removeItem(at: destinationURL)
            completionHandler(destinationURL)
        }

        func downloadDidFinish(_ download: WKDownload) {
            guard let fileURL = downloadURL else { return }
            self.presentShareSheet(fileURL: fileURL)
        }

        func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
            // Hata durumunda sessizce geç
        }
    }
}
