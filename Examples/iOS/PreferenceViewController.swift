import UIKit

final class PreferenceViewController: UIViewController {
    @IBOutlet private weak var urlField: UITextField?
    @IBOutlet private weak var streamNameField: UITextField?
    @IBOutlet private weak var keyFrameIntervalField: UITextField?
    @IBOutlet private weak var keyFrameDurationField: UITextField?
    @IBOutlet private weak var captureResolutionSegmentControl: UISegmentedControl?
    @IBOutlet private weak var bFrameAllowSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        urlField?.text = Preference.defaultInstance.uri
        streamNameField?.text = Preference.defaultInstance.streamName
        keyFrameIntervalField?.text = "\(Preference.defaultInstance.keyframeInterval!)"
        keyFrameDurationField?.text = "\(Preference.defaultInstance.keyframeDuration!)"
        captureResolutionSegmentControl?.selectedSegmentIndex = Preference.defaultInstance.resolution!
        bFrameAllowSwitch?.isOn = Preference.defaultInstance.allowBFrame!
    }

    @IBAction func on(open: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller: UIViewController = storyboard.instantiateViewController(withIdentifier: "PopUpLive")
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func resolutionValueChanged(_ sender: Any) {
        guard let resolutionSegment = sender as? UISegmentedControl else {
            return
        }
        Preference.defaultInstance.resolution = resolutionSegment.selectedSegmentIndex
    }
    @IBAction func bFrameAllowSwitchValueChnged(_ sender: Any) {
        guard let bFrameAllowSwitch = sender as? UISwitch else {
            return
        }
        Preference.defaultInstance.allowBFrame = bFrameAllowSwitch.isOn
    }
}

extension PreferenceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if urlField == textField {
            Preference.defaultInstance.uri = textField.text
        }
        if streamNameField == textField {
            Preference.defaultInstance.streamName = textField.text
        }
        if keyFrameIntervalField == textField {
            Preference.defaultInstance.keyframeInterval = Int(textField.text!)
            print("\(Preference.defaultInstance.keyframeInterval)")
        }
        if keyFrameDurationField == textField {
            Preference.defaultInstance.keyframeDuration = Double(textField.text!)
            print("\(Preference.defaultInstance.keyframeDuration)")
        }
        textField.resignFirstResponder()
        return true
    }
}
