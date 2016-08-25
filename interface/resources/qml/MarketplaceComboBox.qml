//
//  MarketplaceComboBox.qml
//
//  Created by Elisa Lupin-Jimenez on 3 Aug 2016
//  Copyright 2016 High Fidelity, Inc.
//
//  Distributed under the Apache License, Version 2.0.
//  See the accompanying file LICENSE or http://www.apache.org/licenses/LICENSE-2.0.html
//

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtWebChannel 1.0
import QtWebEngine 1.1
import QtWebSockets 1.0
import "qrc:///qtwebchannel/qwebchannel.js" as WebChannel

import "controls"
import "controls-uit" as Controls
import "styles"
import "styles-uit"


Rectangle {
    HifiConstants { id: hifi }
    id: marketplaceComboBox
    anchors.fill: parent
    color: hifi.colors.baseGrayShadow
    property var currentUrl: "https://metaverse.highfidelity.com/marketplace"

    Controls.WebView {
        id: webview
        url: currentUrl
        anchors.top: switchMarketView.bottom
        width: parent.width
        height: parent.height - 40
        focus: true

        Timer {
            id: zipTimer
            running: false
            repeat: false
            interval: 1500
            property var handler;
            onTriggered: handler();
        }

        property var autoCancel: 'var element = $("a.btn.cancel");
                                  element.click();'

        onNewViewRequested: {
            var component = Qt.createComponent("Browser.qml");
            var newWindow = component.createObject(desktop);
            request.openIn(newWindow.webView);
            if (File.isZippedFbx(desktop.currentUrl)) {
                runJavaScript(autoCancel);                
                zipTimer.handler = function() {
                    newWindow.destroy();
                }
                zipTimer.start();
            }
        }

        property var simpleDownload: 'var element = $("a.download-file");
                                      element.removeClass("download-file");
                                      element.removeAttr("download");'

        onLinkHovered: {
            desktop.currentUrl = hoveredUrl;
            // add an error message for non-fbx files
            if (File.isZippedFbx(desktop.currentUrl)) {
                runJavaScript(simpleDownload, function(){console.log("ran the JS");});
            }

        }

    }

    Controls.ComboBox {
        id: switchMarketView
        anchors.top: parent.top
        anchors.right: parent.right
        colorScheme: hifi.colorSchemes.light
        width: 200
        height: 40
        visible: true
        model: ["Marketplace", "Clara.io"]
        onCurrentIndexChanged: {
            if (currentIndex === 0) { webview.url = "https://metaverse.highfidelity.com/marketplace"; }
            if (currentIndex === 1) { webview.url = "https://clara.io/library?public=true&query="; }
        }
        //switchMarketView.textField.color: hifi.colors.white        
    }

    Controls.Label {
        id: switchMarketLabel
        height: switchMarketView.height
        anchors.verticalCenter: switchMarketView.verticalCenter
        anchors.right: switchMarketView.left
        color: hifi.colors.white
        text: "Explore interesting content from: "
    }

    Controls.Button {
        id: switchMarketHelpButton
        height: switchMarketView.height
        width: 60
        anchors.top: parent.top
        anchors.left: parent.left
        visible: switchMarketView.currentIndex === 1
        text: "help"
    }

    Controls.TextField {
        id: helpInfo
        visible: switchMarketHelpButton.pressed === true
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 470
        height: 170
        label: "How to Use Clara.io"
        placeholderText: "1. Sign up/log on to Clara.io to access models\n2. Browse through the library or 'Search 3D Models'\n3. Click the 'Download' button on the model preview page\n4. Select the 'Autodesk FBX (.fbx)' option\n5. Wait for the model to export in the new overlay\n6. Click the yellow 'Download' button\n7. Save your model to the Asset Browser\n8. Select your model from the Asset Browser and 'Load to World'"
    }

}