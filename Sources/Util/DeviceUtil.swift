import AVFoundation

#if os(iOS) || os(macOS)
extension AVFrameRateRange {
    func clamp(rate: Float64) -> Float64 {
        max(minFrameRate, min(maxFrameRate, rate))
    }

    func contains(rate: Float64) -> Bool {
        (minFrameRate...maxFrameRate) ~= rate
    }
}

extension AVCaptureDevice {
    func actualFPS(_ fps: Float64) -> (fps: Float64, duration: CMTime)? {
        var durations: [CMTime] = []
        var frameRates: [Float64] = []

        for range in activeFormat.videoSupportedFrameRateRanges {
            if range.minFrameRate == range.maxFrameRate {
                durations.append(range.minFrameDuration)
                frameRates.append(range.maxFrameRate)
                continue
            }

            if range.contains(rate: fps) {
                return (fps, CMTimeMake(value: 100, timescale: Int32(100 * fps)))
            }

            let actualFPS: Float64 = range.clamp(rate: fps)
            return (actualFPS, CMTimeMake(value: 100, timescale: Int32(100 * actualFPS)))
        }

        let diff = frameRates.map { abs($0 - fps) }

        if let minElement: Float64 = diff.min() {
            for i in 0..<diff.count where diff[i] == minElement {
                return (frameRates[i], durations[i])
            }
        }

        return nil
    }
    
    func findCompatibleFormat(resolution: CMVideoDimensions, fps: Double) -> AVCaptureDevice.Format? {
        var matchFormats: [AVCaptureDevice.Format] = []
        for format in formats {
            if format.formatDescription.dimensions == resolution && format.videoSupportedFrameRateRanges[0].contains(rate:fps) {
                matchFormats.append(format)
                
            }
        }
        var supportVis: [AVCaptureDevice.Format] = []
        for format in matchFormats {
            if format.isVideoStabilizationModeSupported(.auto) {
                supportVis.append(format)
            }
        }
        var supportBinned: [AVCaptureDevice.Format] = []
        for format in matchFormats {
            if format.isVideoBinned {
                supportBinned.append(format)
            }
        }
        var supportWideColor: [AVCaptureDevice.Format] = []
        for format in matchFormats {
            if #available(iOSApplicationExtension 13.0, *) {
                if format.isGlobalToneMappingSupported {
                    supportWideColor.append(format)
                }
            }
        }
        var bestMatchFormats:Set = Set(matchFormats)
        if !bestMatchFormats.intersection(supportVis).isEmpty {
            bestMatchFormats = bestMatchFormats.intersection(supportVis)
        }
        if !bestMatchFormats.intersection(supportBinned).isEmpty {
            bestMatchFormats = bestMatchFormats.intersection(supportBinned)
        }
        if !bestMatchFormats.intersection(supportWideColor).isEmpty {
            bestMatchFormats = bestMatchFormats.intersection(supportWideColor)
        }
        let results = Array(bestMatchFormats)
        if results.isEmpty {
            return activeFormat
        }
        return results[0]
    }
}

// Available Resolution & Framerates
extension AVCaptureDevice {
    func availableDimensions() -> [CMVideoDimensions] {
        var dimensions: [CMVideoDimensions] = []
        for format in formats {
            for dim in dimensions {
                if dim == format.formatDescription.dimensions {
                    continue
                }
            }
            dimensions.append(format.formatDescription.dimensions)
        }
        return dimensions
    }
    
    func availableFrameRateRange(_ dimension:CMVideoDimensions? = nil) -> (minFrameRate: Double, maxFrameRate: Double) {
        let dim: CMVideoDimensions = dimension ?? activeFormat.formatDescription.dimensions
        var frameRate: (minFrameRate:Double, maxFrameRate:Double) = (999, -1)
        for format in formats {
            if format.formatDescription.dimensions == dim {
                let fr: AVFrameRateRange = format.videoSupportedFrameRateRanges[0]
                if fr.minFrameRate < frameRate.minFrameRate {
                    frameRate.minFrameRate = fr.minFrameRate
                }
                if fr.maxFrameRate > frameRate.maxFrameRate{
                    frameRate.maxFrameRate = fr.maxFrameRate
                }
            }
        }
        return frameRate
    }
}

extension CMVideoDimensions {
    static func == (lhs: CMVideoDimensions, rhs: CMVideoDimensions) -> Bool {
        return (lhs.width == rhs.width && lhs.height == rhs.height)
    }
}

public struct DeviceUtil {
    public static func device(withPosition: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.devices().first {
            $0.hasMediaType(.video) && $0.position == withPosition
        }
    }

    public static func device(withLocalizedName: String, mediaType: AVMediaType) -> AVCaptureDevice? {
        AVCaptureDevice.devices().first {
            $0.hasMediaType(mediaType) && $0.localizedName == withLocalizedName
        }
    }
}
#endif
