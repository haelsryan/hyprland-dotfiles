import QtQuick 2.15

Rectangle {
    id: root
    color: "#0a0a0a"

    property string fontName: "JetBrainsMono Nerd Font"
    property color textColor: "#ffffff"
    property color mutedColor: "#d4d4d4"
    property color accent: "#ffffff"
    property color errorColor: "#d96c6c"
    property int sessionIndex: sessionModel.lastIndex
    property bool failed: false

    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.15
    }

    // Gelapkan area atas dan bawah agar teks terbaca
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: parent.height * 0.45
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#cc000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: parent.height * 0.5
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#dd000000" }
        }
    }

    // Jam dan tanggal (kiri atas)
    Column {
        anchors { left: parent.left; top: parent.top; leftMargin: 100; topMargin: 70 }
        spacing: 8

        Text {
            id: clock
            color: root.textColor
            font.family: root.fontName
            font.pixelSize: 110
            font.bold: true
        }

        Row {
            spacing: 14
            Rectangle {
                width: 34; height: 1
                color: root.accent
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: date
                color: root.accent
                font.family: root.fontName
                font.pixelSize: 20
                font.bold: true
                font.letterSpacing: 3
            }
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            clock.text = Qt.formatTime(d, "HH:mm")
            date.text = Qt.formatDate(d, "dddd · MMMM d").toUpperCase()
        }
    }

    // Nama pengguna dan password (kanan bawah)
    Column {
        width: 400
        spacing: 26
        anchors { right: parent.right; bottom: parent.bottom; rightMargin: 60; bottomMargin: 150 }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            text: userModel.lastUser
            color: root.textColor
            font.family: root.fontName
            font.pixelSize: 28
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        Item {
            width: parent.width
            height: 44

            TextInput {
                id: pass
                anchors { left: parent.left; right: arrow.left; rightMargin: 10; verticalCenter: parent.verticalCenter }
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: root.textColor
                font.family: root.fontName
                font.pixelSize: 18
                font.letterSpacing: 2
                focus: true
                onAccepted: sddm.login(userModel.lastUser, pass.text, root.sessionIndex)
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: pass.text.length === 0
                text: root.failed ? "WRONG PASSWORD" : "ENTER PASSWORD"
                color: root.failed ? root.errorColor : root.mutedColor
                font.family: root.fontName
                font.pixelSize: 16
                font.letterSpacing: 3
            }

            Text {
                id: arrow
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                text: "→"
                color: root.accent
                font.pixelSize: 20
                MouseArea {
                    anchors.fill: parent
                    onClicked: sddm.login(userModel.lastUser, pass.text, root.sessionIndex)
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: root.failed ? root.errorColor : root.accent
            }
        }
    }

    // Sesi (kiri bawah), klik untuk membuka daftar sesi
    Column {
        id: sessionPicker
        property bool open: false
        spacing: 14
        anchors { left: parent.left; bottom: parent.bottom; leftMargin: 60; bottomMargin: 50 }

        // Daftar semua sesi (muncul ke atas)
        Column {
            visible: sessionPicker.open
            spacing: 12

            Repeater {
                model: sessionModel
                Text {
                    text: model.name
                    color: (index === root.sessionIndex || itemArea.containsMouse) ? root.textColor : root.mutedColor
                    font.family: root.fontName
                    font.pixelSize: 15
                    font.letterSpacing: 2
                    font.capitalization: Font.AllUppercase
                    leftPadding: 22

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.sessionIndex = index
                            sessionPicker.open = false
                        }
                    }
                }
            }
        }

        // Sesi yang sedang dipilih
        Item {
            width: currentRow.width
            height: currentRow.height

            Row {
                id: currentRow
                spacing: 10

                Text {
                    text: "◆"
                    color: root.accent
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
                Repeater {
                    model: sessionModel
                    Text {
                        visible: index === root.sessionIndex
                        text: model.name
                        color: currentArea.containsMouse ? root.textColor : root.mutedColor
                        font.family: root.fontName
                        font.pixelSize: 15
                        font.letterSpacing: 2
                        font.capitalization: Font.AllUppercase
                    }
                }
                Text {
                    text: sessionPicker.open ? "▴" : "▾"
                    color: root.mutedColor
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: currentArea
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sessionPicker.open = !sessionPicker.open
            }
        }
    }

    // Restart dan Shut down (kanan bawah)
    Row {
        spacing: 40
        anchors { right: parent.right; bottom: parent.bottom; rightMargin: 60; bottomMargin: 50 }

        Text {
            text: "RESTART"
            color: root.mutedColor
            font.family: root.fontName
            font.pixelSize: 15
            font.letterSpacing: 2
            MouseArea { anchors.fill: parent; onClicked: sddm.reboot() }
        }
        Text {
            text: "SHUT DOWN"
            color: root.mutedColor
            font.family: root.fontName
            font.pixelSize: 15
            font.letterSpacing: 2
            MouseArea { anchors.fill: parent; onClicked: sddm.powerOff() }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.failed = true
            pass.text = ""
            failTimer.restart()
        }
    }

    Timer { id: failTimer; interval: 2000; onTriggered: root.failed = false }

    Component.onCompleted: pass.forceActiveFocus()
}
