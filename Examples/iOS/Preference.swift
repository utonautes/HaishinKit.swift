struct Preference {
    static var defaultInstance = Preference()

    var uri: String? = "rtmp://192.168.10.174/live"
    var streamName: String? = "live"
    var keyframeInterval: Int? = 30
    var keyframeDuration: Double? = 1.0
    var resolution: Int? = 2
    var allowBFrame: Bool? = true
}
