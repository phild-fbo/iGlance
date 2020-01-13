//
//  AboutModalViewController.swift
//  iGlance
//
//  Created by Dominik on 10.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class AboutModalViewController: ModalViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var logoImage: NSImageView!
    @IBOutlet private var versionLabel: NSTextField!
    @IBOutlet private var licenseTextView: NSTextView!

    // MARK: -
    // MARK: Function Overrides

    override func viewWillAppear() {
        super.viewWillAppear()

        self.setVersionLabel()
        self.setLicenseView()

        // add a callback to change the logo depending on the current theme
        ThemeManager.onThemeChange(self, #selector(onThemeChange))

        // add the correct logo image at startup
        changeLogo()
    }

    // MARK: -
    // MARK: Private Functions

    @objc
    private func onThemeChange() {
        changeLogo()
    }

    /**
     * Set the version label to the current app version.
     */
    private func setVersionLabel() {
        // get the version of the app
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            DDLogError("Could not retrieve the version of the app")
            return
        }
        versionLabel.stringValue = appVersion
    }

    private func setLicenseView() {
        // get the property list as a dictionary
        guard let plistPath = Bundle.main.path(forResource: "Credits", ofType: "plist") else {
            DDLogError("Could not retrieve Credits.plist")
            return
        }
        guard let creditsDict = NSDictionary(contentsOfFile: plistPath) else {
            DDLogError("Could not cast Credits.plist to a dictionary")
            return
        }

        var licenseViewString = ""
        for key in creditsDict {
            guard let library = creditsDict[key.key] as? [String: String] else {
                DDLogError("Could not cast the library to a [String : String] dictionary")
                continue
            }

            guard let libUrl = library["URL"] else {
                DDLogError("Could not unpack the url of a library")
                continue
            }
            guard let libLicense = library["License"] else {
                DDLogError("Could not unpack the license of a library")
                continue
            }

            // add the title and the url of the library
            var libraryString = "\(key.key) \(libUrl) \n\n"

            // add the license of the library
            libraryString += libLicense

            // add the library string to the license view
            if key.key as? String == "iGlance" {
                // if the current license is from iGlance put it in front of any other license
                licenseViewString = libraryString + "\n\n\n\n" + licenseViewString
            } else {
                licenseViewString += (licenseViewString.isEmpty ? "" : "\n\n\n\n") + libraryString
            }
        }

        // set the content of the license text view
        licenseTextView.string = licenseViewString
    }

    /**
     * Sets the logo according to the current os theme.
     */
    private func changeLogo() {
        if ThemeManager.isDarkTheme() {
            logoImage.image = NSImage(named: "iGlance_logo_white")
        } else {
            logoImage.image = NSImage(named: "iGlance_logo_black")
        }
    }
}
