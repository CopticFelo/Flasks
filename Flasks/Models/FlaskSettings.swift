import Foundation

enum DXTranslationLayer: String, Identifiable, Codable, CaseIterable {
    var id: String { rawValue }
    case wined3d = "WineD3D"
    case dxvk = "DXVK"
    case dxmt = "DXMT"
    case d3dmetal = "D3DMetal"

    var dlls: [String] {
        switch self {
        case .dxvk: return ["d3d11", "d3d10core"]
        default: return []
        }
    }

    var help: String {
        switch self {
        case .wined3d:
            return """
                DirectX 1-11 -> OpenGL
                OpenGL has been deprecated by apple since 2018 so expect bad performance and glitches on older apps/games
                DXVK or DXMT is recommended for DirectX 10 and 11 apps/games
                """
        case .dxvk:
            return """
                DirectX 10 & 11 -> Vulkan
                MacOS doesn't support vulkan so it's translated to Metal through MoltenVK
                DXMT may be better in some cases but it's still in development so expect bugs
                """
        case .dxmt:
            return """
                DirectX 10 & 11 -> Metal
                Still in development
                Often the most preformant way to translate DirectX 10 & 11 but may be buggy
                """
        // NOTE: D3DMetal may need to be downloaded separately due to the license
        case .d3dmetal:
            return """
                DirectX 12 -> Metal
                Part of Apple's Game Porting Toolkit
                """
        }
    }
}

enum WineSync: String, Identifiable, Codable, CaseIterable {
    var id: String { rawValue }
    case msync = "MSync"
    case esync = "ESync"
    case none = "None"

    var getEnvVar: String? {
        switch self {
        case .msync: return "WINEMSYNC"
        case .esync: return "WINEESYNC"
        default: return nil
        }
    }
}

struct FlaskSettings: Codable {
    let prefixPath: URL
    var dxTranslationLayer: DXTranslationLayer
    var sync: WineSync

    mutating func setDXTranslationLayer(to newTL: DXTranslationLayer)
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
    private func symlinkDLLs(_ url: URL) throws(FlaskError) {
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
