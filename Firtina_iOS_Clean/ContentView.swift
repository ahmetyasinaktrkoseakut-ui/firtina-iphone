import SwiftUI
import UIKit
import WebKit
import SafariServices

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
        
        // --- 3. CSS VE JS KURTARMA YAMASI (Yalnızca yerel file:// ana belgesinde çalışır) ---
        let jsCode = """
        (function() {
            if (window.location.protocol !== 'file:') return;
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
        })();
        """
        let script = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        
        // --- IOS DOWNLOAD BRIDGE SCRIPT (atDocumentStart - Yalnızca yerel file:// ana belgesinde çalışır) ---
        let iosDownloadBridgeScriptCode = """
        (function() {
            if (window.location.protocol !== 'file:') return;

            var getUrlPath = function(url) {
                return (url || '').split('?')[0].split('#')[0].toLowerCase();
            };

            var isImageUrl = function(url) {
                if (!url) return false;
                var fullUrl = url.toLowerCase();
                var lower = getUrlPath(url);
                var isImageHost = (fullUrl.indexOf('googleusercontent.com') !== -1 ||
                                   fullUrl.indexOf('oaiusercontent.com') !== -1 ||
                                   fullUrl.indexOf('oaidalleapiprodscus.blob.core.windows.net') !== -1);
                var hasNonImageExt = (lower.endsWith('.pdf') || lower.endsWith('.zip') ||
                                      lower.endsWith('.rar') || lower.endsWith('.tar') ||
                                      lower.endsWith('.gz') || lower.endsWith('.7z') ||
                                      lower.endsWith('.mp3') || lower.endsWith('.m4a') || 
                                      lower.endsWith('.wav') || lower.endsWith('.ogg') || 
                                      lower.endsWith('.aac') || lower.endsWith('.mp4') || 
                                      lower.endsWith('.mov') || lower.endsWith('.webm'));
                if (isImageHost && !hasNonImageExt) return true;
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
        let iosDownloadBridgeScript = WKUserScript(source: iosDownloadBridgeScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(iosDownloadBridgeScript)
        
        // Register script message handlers
        configuration.userContentController.add(context.coordinator, name: "iosDownloadBridge")
        configuration.userContentController.add(context.coordinator, name: "openCustomTab")
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

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, WKScriptMessageHandler, SFSafariViewControllerDelegate {
        var downloadURL: URL?
        var isPresentingShareSheet = false
        var isPresentingSafari = false
        var isPresentingGeminiWebView = false
        weak var presentedSafariVC: SFSafariViewController?
        weak var presentedGeminiVC: GeminiToolWebViewController?
        
        // Handle Javascript message calls (openCustomTab & Blob/Base64/URL Downloads)
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "openCustomTab" {
                let rawUrlString: String?
                if let urlStr = message.body as? String {
                    rawUrlString = urlStr
                } else if let bodyDict = message.body as? [String: Any],
                          let urlStr = bodyDict["url"] as? String {
                    rawUrlString = urlStr
                } else {
                    rawUrlString = nil
                }

                if let rawUrlString = rawUrlString,
                   let validURL = validatedHttpUrl(from: rawUrlString) {
                    openExternalOrToolUrl(validURL)
                }
                return
            }

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

        private func isGeminiShareUrl(_ url: URL) -> Bool {
            guard let host = url.host?.lowercased() else { return false }
            let path = url.path.lowercased()
            if host == "share.gemini.google" || host.hasSuffix(".share.gemini.google") {
                return true
            }
            if host.contains("gemini.google") && path.hasPrefix("/share") {
                return true
            }
            return false
        }

        private func openExternalOrToolUrl(_ url: URL) {
            if isGeminiShareUrl(url) {
                presentGeminiWebViewController(url: url)
            } else {
                presentSafariViewController(url: url)
            }
        }

        private func validatedHttpUrl(from urlString: String) -> URL? {
            let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }
            return validatedHttpUrl(url)
        }

        private func validatedHttpUrl(_ url: URL) -> URL? {
            guard let scheme = url.scheme?.lowercased(),
                  (scheme == "http" || scheme == "https"),
                  let host = url.host,
                  !host.isEmpty else {
                return nil
            }
            return url
        }

        private func topMostViewController() -> UIViewController? {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let activeScene = scenes.first(where: { $0.activationState == .foregroundActive })
                ?? scenes.first(where: { $0.activationState == .foregroundInactive })
                ?? scenes.first

            guard let windowScene = activeScene else { return nil }
            let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
            guard var topVC = keyWindow?.rootViewController else { return nil }

            while true {
                if let presented = topVC.presentedViewController {
                    topVC = presented
                } else if let navigation = topVC as? UINavigationController, let visible = navigation.visibleViewController {
                    topVC = visible
                } else if let tab = topVC as? UITabBarController, let selected = tab.selectedViewController {
                    topVC = selected
                } else {
                    break
                }
            }
            return topVC
        }

        private func presentGeminiWebViewController(url: URL) {
            guard let validURL = validatedHttpUrl(url) else { return }

            DispatchQueue.main.async {
                if let existingGemini = self.presentedGeminiVC,
                   existingGemini.presentingViewController == nil && !existingGemini.isBeingPresented {
                    self.presentedGeminiVC = nil
                    self.isPresentingGeminiWebView = false
                }

                if self.isPresentingGeminiWebView || self.isPresentingSafari || self.isPresentingShareSheet {
                    return
                }

                guard let topVC = self.topMostViewController() else {
                    return
                }

                if topVC is SFSafariViewController || topVC is UIActivityViewController || topVC is GeminiToolWebViewController || topVC.presentedViewController != nil {
                    return
                }

                self.isPresentingGeminiWebView = true

                let geminiVC = GeminiToolWebViewController(url: validURL, coordinator: self) { [weak self] in
                    DispatchQueue.main.async {
                        self?.presentedGeminiVC = nil
                        self?.isPresentingGeminiWebView = false
                    }
                }
                geminiVC.modalPresentationStyle = .fullScreen

                self.presentedGeminiVC = geminiVC
                topVC.present(geminiVC, animated: true) {
                    if geminiVC.presentingViewController == nil {
                        self.presentedGeminiVC = nil
                        self.isPresentingGeminiWebView = false
                    }
                }
            }
        }

        private func presentSafariViewController(url: URL) {
            guard let validURL = validatedHttpUrl(url) else { return }

            DispatchQueue.main.async {
                if let existingSafari = self.presentedSafariVC,
                   existingSafari.presentingViewController == nil && !existingSafari.isBeingPresented {
                    self.presentedSafariVC = nil
                    self.isPresentingSafari = false
                }

                if self.isPresentingSafari || self.isPresentingShareSheet || self.isPresentingGeminiWebView {
                    return
                }

                guard let topVC = self.topMostViewController() else {
                    return
                }

                if topVC is SFSafariViewController || topVC is UIActivityViewController || topVC is GeminiToolWebViewController || topVC.presentedViewController != nil {
                    return
                }

                self.isPresentingSafari = true

                let safariConfig = SFSafariViewController.Configuration()
                safariConfig.entersReaderIfAvailable = false
                safariConfig.barCollapsingEnabled = false

                let safariVC = SFSafariViewController(url: validURL, configuration: safariConfig)
                safariVC.delegate = self
                safariVC.dismissButtonStyle = .done
                safariVC.modalPresentationStyle = .fullScreen

                self.presentedSafariVC = safariVC
                topVC.present(safariVC, animated: true) {
                    if safariVC.presentingViewController == nil {
                        self.presentedSafariVC = nil
                        self.isPresentingSafari = false
                    }
                }
            }
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            DispatchQueue.main.async {
                self.presentedSafariVC = nil
                self.isPresentingSafari = false
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
            if mime.contains("rar") { return "rar" }
            if mime.contains("tar") { return "tar" }
            if mime.contains("gzip") || mime.contains("x-gzip") { return "gz" }
            if mime.contains("7z") || mime.contains("7-zip") { return "7z" }
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
                "txt", "csv", "json", "zip", "rar", "tar", "gz", "7z",
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
                if self.isPresentingShareSheet || self.isPresentingSafari {
                    print("Warning: Modal presentation is already in progress, ignoring duplicate request.")
                    return
                }

                guard let topVC = self.topMostViewController() else {
                    print("Error: Could not find key window root VC")
                    return
                }
                
                // CRITICAL SAFETY CHECK: Prevent double presentation crashes
                if topVC is UIActivityViewController || topVC is SFSafariViewController || topVC.presentedViewController != nil {
                    print("Warning: Modal is already presented, ignoring duplicate request.")
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

        // Ana frame'e giden tüm harici http/https isteklerini WKWebView'da iptal et ve uygun ekranda aç
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               let validURL = validatedHttpUrl(url) {
                let isMainFrameOrNewWindow = (navigationAction.targetFrame == nil) || (navigationAction.targetFrame?.isMainFrame == true)
                if isMainFrameOrNewWindow && !navigationAction.shouldPerformDownload {
                    decisionHandler(.cancel)
                    openExternalOrToolUrl(validURL)
                    return
                }
            }

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

        // target="_blank" veya window.open ile açılan harici linkleri WKWebView'a yükleme; uygun ekranda aç
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil,
               let url = navigationAction.request.url,
               let validURL = validatedHttpUrl(url) {
                openExternalOrToolUrl(validURL)
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

final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

final class GeminiToolWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let initialURL: URL
    private weak var coordinator: WebView.Coordinator?
    private let onDismiss: () -> Void
    private var webView: WKWebView?
    private var hasNotifiedDismiss = false

    init(url: URL, coordinator: WebView.Coordinator, onDismiss: @escaping () -> Void) {
        self.initialURL = url
        self.coordinator = coordinator
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 8/255, green: 8/255, blue: 10/255, alpha: 1.0)

        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
        view.addSubview(topBar)

        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Bitti", for: .normal)
        closeButton.setTitleColor(UIColor(red: 56/255, green: 189/255, blue: 248/255, alpha: 1.0), for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        topBar.addSubview(closeButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Fotoğraf Uygulaması"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textAlignment = .center
        topBar.addSubview(titleLabel)

        let reloadButton = UIButton(type: .system)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.setTitle("↻", for: .normal)
        reloadButton.setTitleColor(.white, for: .normal)
        reloadButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        topBar.addSubview(reloadButton)

        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.allowsInlineMediaPlayback = true
        configuration.websiteDataStore = .default()

        let otPatchScriptCode = """
        (function() {
            try {
                if (window.location && window.location.hostname && window.location.hostname.indexOf('gemini.google') !== -1 && !window.__firtinaOtPatched) {
                    window.__firtinaOtPatched = true;
                    var origFetch = window.fetch;
                    if (origFetch) {
                        window.fetch = async function(input, init) {
                            var url = typeof input === 'string' ? input : (input && input.url ? input.url : '');
                            var res = await origFetch.apply(this, arguments);
                            if (url.indexOf('otAQ7b') !== -1) {
                                try {
                                    var clone = res.clone();
                                    var txt = await clone.text();
                                    var modified = txt.replace(/,1016,/g, ',1000,');
                                    return new Response(modified, { status: res.status, statusText: res.statusText, headers: res.headers });
                                } catch (e) {}
                            }
                            return res;
                        };
                    }
                    var origOpen = XMLHttpRequest.prototype.open;
                    XMLHttpRequest.prototype.open = function(method, url) {
                        this.__firtinaUrl = typeof url === 'string' ? url : String(url || '');
                        return origOpen.apply(this, arguments);
                    };
                    var respTextDesc = Object.getOwnPropertyDescriptor(XMLHttpRequest.prototype, 'responseText');
                    if (respTextDesc && respTextDesc.get) {
                        Object.defineProperty(XMLHttpRequest.prototype, 'responseText', {
                            get: function() {
                                var val = respTextDesc.get.call(this);
                                if (this.__firtinaUrl && this.__firtinaUrl.indexOf('otAQ7b') !== -1 && typeof val === 'string') {
                                    return val.replace(/,1016,/g, ',1000,');
                                }
                                return val;
                            }
                        });
                    }
                    var respDesc = Object.getOwnPropertyDescriptor(XMLHttpRequest.prototype, 'response');
                    if (respDesc && respDesc.get) {
                        Object.defineProperty(XMLHttpRequest.prototype, 'response', {
                            get: function() {
                                var val = respDesc.get.call(this);
                                if (this.__firtinaUrl && this.__firtinaUrl.indexOf('otAQ7b') !== -1 && typeof val === 'string') {
                                    return val.replace(/,1016,/g, ',1000,');
                                }
                                return val;
                            }
                        });
                    }
                }
            } catch (e) {}
        })();
        """
        let otPatchScript = WKUserScript(source: otPatchScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(otPatchScript)

        let multiFrameDownloadBridgeScriptCode = """
        (function() {
            if (window.IosDownloadBridgeInjected) return;
            window.IosDownloadBridgeInjected = true;

            try {
                if (navigator && navigator.canShare) {
                    navigator.canShare = function() { return false; };
                }
            } catch (e) {}

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
                       lower.endsWith('.pdf') || lower.endsWith('.zip') ||
                       lower.endsWith('.mp3') || lower.endsWith('.m4a') ||
                       lower.endsWith('.wav') || lower.endsWith('.ogg') ||
                       lower.endsWith('.aac') || lower.endsWith('.mp4') ||
                       lower.endsWith('.mov') || lower.endsWith('.webm');
            };

            var getMimeFromDataUrl = function(url) {
                var match = /^data:([^;,]+)/i.exec(url || '');
                return match && match[1] ? match[1] : 'application/octet-stream';
            };

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
                } else if (window.top && window.top !== window) {
                    window.top.postMessage({
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
                } else if (window.top && window.top !== window) {
                    window.top.postMessage({
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
        let multiFrameDownloadBridgeScript = WKUserScript(source: multiFrameDownloadBridgeScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(multiFrameDownloadBridgeScript)

        if let coordinator = coordinator {
            configuration.userContentController.add(WeakScriptMessageHandler(delegate: coordinator), name: "iosDownloadBridge")
        }

        let createdWebView = WKWebView(frame: .zero, configuration: configuration)
        createdWebView.translatesAutoresizingMaskIntoConstraints = false
        createdWebView.navigationDelegate = self
        createdWebView.uiDelegate = self
        createdWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
        createdWebView.isOpaque = false
        createdWebView.backgroundColor = UIColor(red: 8/255, green: 8/255, blue: 10/255, alpha: 1.0)
        createdWebView.scrollView.backgroundColor = UIColor(red: 8/255, green: 8/255, blue: 10/255, alpha: 1.0)
        createdWebView.allowsBackForwardNavigationGestures = true
        view.addSubview(createdWebView)
        self.webView = createdWebView

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 48),

            closeButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: closeButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: reloadButton.leadingAnchor, constant: -8),

            reloadButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            reloadButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            createdWebView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            createdWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createdWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createdWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        createdWebView.load(URLRequest(url: initialURL))
    }

    private func cleanupAndNotifyDismiss() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "iosDownloadBridge")
        webView?.stopLoading()
        if !hasNotifiedDismiss {
            hasNotifiedDismiss = true
            onDismiss()
        }
    }

    @objc private func closeTapped() {
        cleanupAndNotifyDismiss()
        dismiss(animated: true, completion: nil)
    }

    @objc private func reloadTapped() {
        webView?.reload()
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "iosDownloadBridge")
        if !hasNotifiedDismiss {
            hasNotifiedDismiss = true
            onDismiss()
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.shouldPerformDownload {
            decisionHandler(.download)
            return
        }

        if let url = navigationAction.request.url,
           let scheme = url.scheme?.lowercased() {
            if scheme != "http" && scheme != "https" && scheme != "blob" && scheme != "data" && scheme != "about" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }

            if let host = url.host?.lowercased(),
               (navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == true),
               (host.contains("instagram.com") || host.contains("wa.me") || host.contains("whatsapp.com")) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
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
        download.delegate = coordinator
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = coordinator
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            let host = url.host?.lowercased() ?? ""
            if host.contains("instagram.com") || host.contains("wa.me") || host.contains("whatsapp.com") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if url.scheme == "http" || url.scheme == "https" {
                webView.load(URLRequest(url: url))
            }
        }
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
            completionHandler()
        })
        if presentedViewController == nil {
            present(alert, animated: true, completion: nil)
        } else {
            completionHandler()
        }
    }
}
