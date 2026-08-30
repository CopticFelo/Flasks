import Foundation

enum DXTranslationLayer: Identifiable, Codable {
    case wined3d
    case dxvk(hud: Bool)
    case dxmt
    case d3dmetal

    var dlls: [String] {
        switch self {
        case .dxvk: return ["d3d11", "d3d10core"]
        default: return []
        }
    }

    var id: String { prettyPrint() }
    func prettyPrint() -> String {
        switch self {
        case .wined3d: return "WineD3D"
        case .dxvk: return "DXVK"
        case .dxmt: return "DXMT"
        case .d3dmetal: return "D3DMetal"
        }
    }
}

struct FlaskSettings: Codable {
    let prefixPath: URL
    var dxTranslationLayer: DXTranslationLayer
    var msync: Bool

    mutating func setDXTranslationLayer(to newTL: DXTranslationLayer, prefix: URL)
        throws(FlaskError)
    {
        dxTranslationLayer = newTL
        switch newTL {
        case .dxvk: try setDXVK()
        default: return
        }
    }

    func setDXVK() throws(FlaskError) {
        let dllUrl = Bundle.main.sharedSupportURL?.appending(path: "lib").appending(path: "dxvk")
        guard let dllUrl else { throw FlaskError.fileError(detail: CocoaError(.fileNoSuchFile)) }
        try symlinkDLLs(dllUrl)
    }

    /// Creates symlinks in system32 & syswow64 to the DLLs in the @url
    /// DLLs in syswow64 -> the ones in i386-windows
    /// DLLs in system32 -> the ones in x86_64-windows
    func symlinkDLLs(_ url: URL) throws(FlaskError) {
        let dlls32 = url.appending(path: "i386-windows")
        let syswow64 = self.prefixPath.appending(path: "drive_c/windows/syswow64")
        let dlls64 = url.appending(path: "x86_64-windows")
        let system32 = self.prefixPath.appending(path: "drive_c/windows/system32")
        do {
            let contents32 = try FileManager.default.contentsOfDirectory(atPath: dlls32.path)
            for dll in contents32 {
                let symlinkPath = syswow64.appending(path: dll)
                if FileManager.default.fileExists(atPath: symlinkPath.path) {
                    try FileManager.default.removeItem(at: symlinkPath)
                }
                try FileManager.default.createSymbolicLink(
                    at: symlinkPath,
                    withDestinationURL: dlls32.appending(path: dll))
            }

            let contents64 = try FileManager.default.contentsOfDirectory(atPath: dlls64.path)
            for dll in contents64 {
                let symlinkPath = system32.appending(path: dll)
                if FileManager.default.fileExists(atPath: symlinkPath.path) {
                    try FileManager.default.removeItem(at: symlinkPath)
                }
                try FileManager.default.createSymbolicLink(
                    at: symlinkPath,
                    withDestinationURL: dlls64.appending(path: dll))
            }
        } catch let error as CocoaError {
            throw FlaskError.fileError(detail: error)
        } catch {
            throw FlaskError.unknownError
        }
    }

}
