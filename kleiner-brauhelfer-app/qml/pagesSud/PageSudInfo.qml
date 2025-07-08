import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "../common"
import brauhelfer

PageBase {
    id: page
    title: qsTr("Sudinfo")
    icon: "ic_info_outline.png"
    enabled: Sud.isLoaded
    readOnly: Brauhelfer.readonly || app.settings.readonly

    Flickable {
        anchors.fill: parent
        anchors.margins: 8
        clip: true
        contentHeight: layout.height + 8
        boundsBehavior: Flickable.OvershootBounds
        ScrollIndicator.vertical: ScrollIndicator { }
        MouseAreaCatcher {}
        ColumnLayout {
            id: layout
            spacing: 8
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8

            TextFieldBase {
                Layout.fillWidth: true
                enabled: !page.readOnly
                placeholderText: qsTr("Sudname")
                text: Sud.Sudname
                onTextChanged: if (activeFocus) Sud.Sudname = text
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Sudnummer")
                }
                SpinBoxReal {
                    Layout.fillWidth: true
                    enabled: !page.readOnly
                    decimals: 0
                    max: 9999
                    realValue: Sud.Sudnummer
                    onNewValue: (value) => Sud.Sudnummer = value
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Kategorie")
                }
                ComboBoxBase {
                    Layout.fillWidth: true
                    enabled: !page.readOnly
                    model: Brauhelfer.modelKategorien
                    textRole: "Name"
                    currentIndex: Qt.binding(findme)
                    onActivated: Sud.Kategorie = currentText
                    Component.onCompleted: {
                        currentIndex = Qt.binding(function(){return find(Sud.Kategorie)})
                    }
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Anlage")
                }
                LabelPrim {
                    text: Sud.Anlage
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Status")
                }
                LabelPrim {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        switch (Sud.Status) {
                        case Brauhelfer.Rezept:
                            return qsTr("nicht gebraut")
                        case Brauhelfer.Gebraut:
                            return qsTr("nicht abgefüllt")
                        case Brauhelfer.Abgefuellt:
                            var tage = Sud.ReifezeitDelta
                            if (tage > 0)
                                return qsTr("reif in") + " " + tage + " " + qsTr("Tage")
                            else
                                return qsTr("reif seit") + " " + Math.floor(-tage / 7) + " " + qsTr("Wochen")
                        case Brauhelfer.Verbraucht:
                            return qsTr("verbraucht")
                        }
                    }
                }
                SwitchBase {
                    Layout.fillWidth: true
                    enabled: !page.readOnly && app.brewForceEditable
                    text: qsTr("Gebraut")
                    checked: Sud.Status >= Brauhelfer.Gebraut
                    onClicked: Sud.Status = checked ? Brauhelfer.Gebraut : Brauhelfer.Rezept
                }
                LabelDate {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    date: Sud.Braudatum
                }
                SwitchBase {
                    Layout.fillWidth: true
                    enabled: !page.readOnly && app.brewForceEditable
                    text: qsTr("Abgefüllt")
                    checked: Sud.Status >= Brauhelfer.Abgefuellt
                    onClicked: Sud.Status = checked ? Brauhelfer.Abgefuellt : Brauhelfer.Gebraut
                }
                LabelDate {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    date: Sud.Abfuelldatum
                }
                SwitchBase {
                    Layout.fillWidth: true
                    enabled: !page.readOnly && (Sud.Status >= Brauhelfer.Abgefuellt || app.brewForceEditable)
                    text: qsTr("Verbraucht")
                    checked: Sud.Status >= Brauhelfer.Verbraucht
                    onClicked: Sud.Status = checked ? Brauhelfer.Verbraucht : Brauhelfer.Abgefuellt
                }
                LabelPrim {
                    Layout.fillWidth: true
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Erstellt")
                }
                LabelDate {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    date: Sud.Erstellt
                }
                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Gespeichert")
                }
                LabelDateTime {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    date: Sud.Gespeichert
                }
                LabelPrim {
                    Layout.fillWidth: true
                    visible: Sud.BewertungMittel > 0
                    text: qsTr("Bewertung")
                }
                Flow {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    visible: Sud.BewertungMittel > 0
                    Image {
                        width: 16
                        height: 16
                        source: Sud.BewertungMittel > 0 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                    Image {
                        width: 16
                        height: 16
                        source: Sud.BewertungMittel > 1 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                    Image {
                        width: 16
                        height: 16
                        source: Sud.BewertungMittel > 2 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                    Image {
                        width: 16
                        height: 16
                        source: Sud.BewertungMittel > 3 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                    Image {
                        width: 16
                        height: 16
                        source: Sud.BewertungMittel > 4 ? "qrc:/images/ic_star.png" : "qrc:/images/ic_star_border.png"
                    }
                }
            }

            HorizontalDivider {
                Layout.columnSpan: 4
                Layout.fillWidth: true
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                columnSpacing: 16

                LabelPrim {
                    Layout.fillWidth: true
                    visible: Sud.Status !== Brauhelfer.Rezept
                    text: " "
                }
                LabelPrim {
                    visible: Sud.Status !== Brauhelfer.Rezept
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    text: qsTr("Sud")
                }
                LabelPrim {
                    visible: Sud.Status !== Brauhelfer.Rezept
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    text: qsTr("Rezept")
                }
                LabelUnit {
                    visible: Sud.Status !== Brauhelfer.Rezept
                    text: " "
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Menge")
                }
                LabelNumber {
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.Menge : Sud.MengeIst
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.Menge
                }
                LabelUnit {
                    text: qsTr("L")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Stammwürze")
                }
                LabelPlato {
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.SW : Sud.SWIst
                }
                LabelPlato {
                    opacity: app.config.textOpacityHalf
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.SW
                }
                LabelUnit {
                    text: qsTr("°P")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Sudhausausbeute")
                }
                LabelNumber {
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.Sudhausausbeute : Sud.erg_EffektiveAusbeute
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.Sudhausausbeute
                }
                LabelUnit {
                    text: qsTr("%")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Vergärungsgrad")
                }
                LabelNumber {
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.Vergaerungsgrad : BierCalc.vergaerungsgrad(Sud.SWIst, Sud.SREIst)
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.Vergaerungsgrad
                }
                LabelUnit {
                    text: qsTr("%")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Restextrakt")
                }
                LabelPlato {
                    value: Sud.Status === Brauhelfer.Rezept ? BierCalc.sreAusVergaerungsgrad(Sud.SW, Sud.Vergaerungsgrad) : Sud.SREIst
                }
                LabelPlato {
                    opacity: app.config.textOpacityHalf
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : BierCalc.sreAusVergaerungsgrad(Sud.SW, Sud.Vergaerungsgrad)
                }
                LabelUnit {
                    text: qsTr("°P")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Alkoholgehalt")
                }
                LabelNumber {
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.AlkoholSoll : Sud.erg_Alkohol
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.AlkoholSoll
                }
                LabelUnit {
                    text: qsTr("%vol")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Bittere")
                }
                LabelNumber {
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.IBU : Sud.IbuIst
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.IBU
                }
                LabelUnit {
                    text: qsTr("IBU")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Farbe")
                }
                LabelNumber {
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.erg_Farbe : Sud.FarbeIst
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.erg_Farbe
                }
                LabelUnit {
                    text: qsTr("EBC")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Karbonisierung (CO2)")
                }
                LabelNumber {
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.CO2 : Sud.CO2Ist
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.CO2
                }
                LabelUnit {
                    text: qsTr("g/l")
                }

                LabelPrim {
                    visible: Sud.RestalkalitaetSoll !== 0
                    Layout.fillWidth: true
                    text: qsTr("Restalkalität")
                }
                LabelNumber {
                    visible: Sud.RestalkalitaetSoll !== 0
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ?  Sud.RestalkalitaetSoll : Sud.RestalkalitaetIst
                }
                LabelNumber {
                    visible: Sud.RestalkalitaetSoll !== 0
                    opacity: app.config.textOpacityHalf
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.RestalkalitaetSoll
                }
                LabelUnit {
                    visible: Sud.RestalkalitaetSoll !== 0
                    text: qsTr("°dH")
                }

                LabelPrim {
                    visible: tbPh.value > 0
                    Layout.fillWidth: true
                    text: qsTr("pH-Wert")
                }
                LabelNumber {
                    id: tbPh
                    visible: tbPh.value > 0
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ?  Sud.PhMaischeSoll : Sud.PhMaische
                }
                LabelNumber {
                    visible: tbPh.value > 0
                    opacity: app.config.textOpacityHalf
                    precision: 1
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.PhMaischeSoll
                }
                LabelUnit {
                    visible: tbPh.value > 0
                    text: ""
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Reifezeit")
                }
                LabelNumber {
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Sud.Reifezeit : Number.NaN
                }
                LabelNumber {
                    opacity: app.config.textOpacityHalf
                    precision: 0
                    value: Sud.Status === Brauhelfer.Rezept ? Number.NaN : Sud.Reifezeit
                }
                LabelUnit {
                    text: qsTr("Wochen")
                }

                LabelPrim {
                    Layout.fillWidth: true
                    text: qsTr("Gesamtkosten")
                }
                LabelNumber {
                    Layout.columnSpan: 2
                    precision: 2
                    value: Sud.erg_Preis
                }
                LabelUnit {
                    text: Qt.locale().currencySymbol() + "/" + qsTr("L")
                }
            }

            HorizontalDivider {
                Layout.fillWidth: true
            }

            TextAreaBase {
                Layout.fillWidth: true
                opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                wrapMode: TextArea.Wrap
                placeholderText: qsTr("Bemerkung Rezept")
                textFormat: Text.RichText
                text: Sud.Kommentar
                onLinkActivated: (link) => Qt.openUrlExternally(link)
                onTextChanged: if (activeFocus) Sud.Kommentar = text
            }
        }
    }
}
