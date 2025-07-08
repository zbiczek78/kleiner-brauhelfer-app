import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "../common"
import brauhelfer
import ProxyModel

PageBase {
    id: page
    title: qsTr("Abfüllen")
    icon: "abfuellen.png"
    readOnly: Brauhelfer.readonly || app.settings.readonly || (Sud.Status !== Brauhelfer.Gebraut && !app.brewForceEditable)

    Flickable {
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        contentHeight: layout.height
        boundsBehavior: Flickable.OvershootBounds
        ScrollIndicator.vertical: ScrollIndicator {}

        function abgefuellt() {
            var bereit = true;
            if (!Sud.AbfuellenBereitZutaten) {
                bereit = false;
            }
            else if (Sud.SchnellgaerprobeAktiv) {
                if (Sud.SWJungbier > Sud.Gruenschlauchzeitpunkt)
                    bereit = false;
                else if (Sud.SWJungbier < Sud.SWSchnellgaerprobe)
                    bereit = false;
            }
            if (bereit) {
                Sud.Abfuelldatum = tfAbfuelldatum.date
                Sud.Status = Brauhelfer.Abgefuellt
                var values = {"SudID": Sud.id,
                              "Zeitstempel": Sud.Abfuelldatum,
                              "Temp": Sud.TemperaturJungbier }
                if (Sud.modelNachgaerverlauf.rowCount() === 0)
                    Sud.modelNachgaerverlauf.append(values)
            }
        }

        ColumnLayout {
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            GroupBox {
                visible: listViewWeitereZutaten.count > 0
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                contentHeight: contentLayout.height
                label: LabelHeader {
                    text: qsTr("Zusätze")
                }
                ColumnLayout {
                    id: contentLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    ListView {
                        id: listViewWeitereZutaten
                        Layout.fillWidth: true
                        height: contentHeight
                        interactive: false
                        model: ProxyModel {
                            sourceModel: Sud.modelWeitereZutatenGaben
                            filterKeyColumn: fieldIndex("Zeitpunkt")
                            filterRegularExpression: /0/
                        }
                        delegate: ItemDelegate {
                            enabled: !page.readOnly
                            width: listViewWeitereZutaten.width
                            height: dataColumn.implicitHeight
                            onClicked: {
                                listViewWeitereZutaten.currentIndex = index
                                popuploaderWeitereZutaten.active = true
                            }
                            ColumnLayout {
                                id: dataColumn
                                anchors.left: parent.left
                                anchors.right: parent.right
                                RowLayout {
                                    spacing: 16
                                    Layout.topMargin: 4
                                    Layout.bottomMargin: 4
                                    Layout.fillWidth: true
                                    LabelPrim {
                                        Layout.fillWidth: true
                                        text: model.Name
                                    }
                                    LabelPrim {
                                        text: {
                                            switch (model.Zugabestatus)
                                            {
                                            case 0: return qsTr("nicht zugegeben")
                                            case 1: return model.Entnahmeindex === 0 ? qsTr("zugegeben seit") : qsTr("zugegeben")
                                            case 2: return qsTr("entnommen nach")
                                            default: return ""
                                            }
                                        }
                                    }
                                    LabelNumber {
                                        visible: model.Zugabestatus > 0 && model.Entnahmeindex === 0
                                        precision: 0
                                        value: {
                                            switch (model.Zugabestatus)
                                            {
                                            case 1: return (new Date().getTime() - model.ZugabeDatum.getTime()) / 1440 / 60000
                                            case 2: return model.Zugabedauer/ 1440
                                            default: return 0.0
                                            }
                                        }
                                        unit: qsTr("Tage")
                                    }
                                }
                            }
                        }
                    }
                    LabelPrim {
                        visible: Sud.Status === Brauhelfer.Gebraut && !Sud.AbfuellenBereitZutaten
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                        text: qsTr("Zutaten noch nicht zugegeben oder entnommen.")
                    }
                }

                Loader {
                    id: popuploaderWeitereZutaten
                    active: false
                    onLoaded: item.open()
                    sourceComponent: PopupWeitereZutatenGaben {
                        model: listViewWeitereZutaten.model
                        currentIndex: listViewWeitereZutaten.currentIndex
                        onClosed: popuploaderWeitereZutaten.active = false
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Restextrakt Schnellgärprobe")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    SwitchBase {
                        id: ctrlSGPen
                        Layout.columnSpan: 3
                        text: qsTr("Aktiviert")
                        enabled: !page.readOnly
                        checked: Sud.SchnellgaerprobeAktiv
                        onClicked: Sud.SchnellgaerprobeAktiv = checked
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: ctrlSGPen.checked
                        text: qsTr("Restextrakt")
                    }
                    TextFieldSre {
                        enabled: !page.readOnly && ctrlSGPen.checked
                        visible: ctrlSGPen.checked
                        sw: Sud.SWIst
                        value: Sud.SWSchnellgaerprobe
                        onNewValue: (value) => Sud.SWSchnellgaerprobe = value
                    }
                    LabelUnit {
                        visible: ctrlSGPen.checked
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: ctrlSGPen.checked
                        text: qsTr("Grünschlauchzeitpunkt")
                    }
                    LabelPlato {
                        id: ctrlGS
                        horizontalAlignment: Text.AlignHCenter
                        visible: ctrlSGPen.checked
                        value: Sud.Gruenschlauchzeitpunkt
                    }
                    LabelUnit {
                        visible: ctrlSGPen.checked
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: ctrlSGPen.checked && Sud.SWJungbier < Sud.SWSchnellgaerprobe
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                        text: qsTr("Jungbier liegt tiefer als Schnellgärprobe.")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Restextrakt Jungbier")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Restextrakt")
                    }
                    TextFieldSre {
                        enabled: !page.readOnly
                        sw: Sud.SWIst
                        value: Sud.SWJungbier
                        onNewValue: (value) => Sud.SWJungbier = value
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        text: qsTr("Erwartet")
                    }
                    LabelPlato {
                        value: BierCalc.sreAusVergaerungsgrad(Sud.SWIst, Sud.Vergaerungsgrad)
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        visible: ctrlSGPen.checked && Sud.SWJungbier > Sud.Gruenschlauchzeitpunkt
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                        text: qsTr("Grünschlauchzeitpunkt noch nicht erreicht.")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Vergärung")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Stammwürze")
                    }
                    LabelPlato {
                        horizontalAlignment: Text.AlignHCenter
                        value: Sud.SWIst
                    }
                    LabelUnit {
                        text: qsTr("°P")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Vergärungsgrad")
                    }
                    LabelNumber {
                        value: BierCalc.vergaerungsgrad(Sud.SWIst, Sud.SREIst)
                    }
                    LabelUnit {
                        text: qsTr("%")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        text: qsTr("Aus Rezept")
                    }
                    LabelNumber {
                        precision: 1
                        value: Sud.Vergaerungsgrad
                    }
                    LabelUnit {
                        text: qsTr("%")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Alkoholgehalt")
                    }
                    LabelNumber {
                        id: ctrlAlc
                        precision: 1
                        value: Sud.erg_Alkohol
                    }
                    LabelUnit {
                        text: qsTr("%vol")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        text: qsTr("Aus Rezept")
                    }
                    LabelNumber {
                        precision: 1
                        value: Sud.AlkoholSoll
                    }
                    LabelUnit {
                        text: qsTr("%vol")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Jungbier")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Jungbiermenge")
                    }
                    TextFieldVolume {
                        id: ctrlJungbiermenge
                        enabled: !page.readOnly
                        useDialog: false
                        value: Sud.JungbiermengeAbfuellen
                        onNewValue: (value) => Sud.JungbiermengeAbfuellen = value
                    }
                    LabelUnit {
                        text: qsTr("L")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Verlust seit Anstellen")
                    }
                    LabelNumber {
                        value: Sud.WuerzemengeAnstellen - Sud.JungbiermengeAbfuellen
                    }
                    LabelUnit {
                        text: qsTr("L")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Temperatur Jungbier")
                    }
                    TextFieldTemperature {
                        enabled: !page.readOnly
                        value: Sud.TemperaturJungbier
                        onNewValue: (value) => Sud.TemperaturJungbier = value
                    }
                    LabelUnit {
                        text: qsTr("°C")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Spundungsdruck")
                    }
                    LabelNumber {
                        precision: 2
                        value: Sud.Spundungsdruck
                    }
                    LabelUnit {
                        text: qsTr("bar")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Karbonisierung")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 5
                    SwitchBase {
                        id: ctrlSpunden
                        Layout.columnSpan: 5
                        text: qsTr("Spunden")
                        enabled: !page.readOnly
                        checked: Sud.Spunden
                        onClicked: Sud.Spunden = checked
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        visible: !ctrlSpunden.checked
                        text: qsTr("Temperatur")
                    }
                    TextFieldTemperature {
                        enabled: !page.readOnly
                        visible: !ctrlSpunden.checked
                        value: Sud.TemperaturKarbonisierung
                        onNewValue: (value) => Sud.TemperaturKarbonisierung = value
                    }
                    LabelUnit {
                        visible: !ctrlSpunden.checked
                        text: qsTr("°C")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        visible: tbZuckerAnteil.visible
                        text: qsTr("Süsskraft Zucker")
                    }
                    TextFieldNumber {
                        Layout.columnSpan: 2
                        visible: tbZuckerAnteil.visible
                        min: 0.0
                        max: 2.0
                        precision: 2
                        enabled: !page.readOnly
                        value: app.settings.sugarFactor
                        onNewValue: (value) => app.settings.sugarFactor = value
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        visible: !ctrlSpunden.checked
                        text: qsTr("Wasser Zuckerlösung")
                    }
                    TextFieldNumber {
                        visible: !ctrlSpunden.checked
                        precision: 2
                        enabled: !page.readOnly
                        value: Sud.VerschneidungAbfuellen
                        onNewValue: (value) => Sud.VerschneidungAbfuellen = value
                    }
                    LabelUnit {
                        visible: !ctrlSpunden.checked
                        text: qsTr("L")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        Layout.columnSpan: 3
                        visible: !ctrlSpunden.checked
                        text: qsTr("Verfügbare Speisemenge")
                    }
                    TextFieldNumber {
                        visible: !ctrlSpunden.checked
                        enabled: !page.readOnly
                        precision: 2
                        value: Sud.Speisemenge
                        onNewValue: (value) => Sud.Speisemenge = value
                    }
                    LabelUnit {
                        visible: !ctrlSpunden.checked
                        text: qsTr("L")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: tbSpeiseAnteil.visible
                        text: qsTr("Benötigte Speisemenge")
                    }
                    LabelNumber {
                        id: tbSpeiseAnteil
                        visible: !ctrlSpunden.checked
                        precision: 0
                        value: Sud.SpeiseAnteil
                    }
                    LabelUnit {
                        visible: tbSpeiseAnteil.visible
                        text: qsTr("mL")
                    }
                    LabelNumber {
                        horizontalAlignment: Text.AlignHCenter
                        visible: tbSpeiseAnteil.visible
                        precision: 1
                        value: Sud.JungbiermengeAbfuellen > 0.0 ? Sud.SpeiseAnteil / Sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelUnit {
                        visible: tbSpeiseAnteil.visible
                        text: qsTr("mL/L")
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: tbZuckerAnteil.visible
                        text: qsTr("Benötigte Zuckermenge")
                    }
                    LabelNumber {
                        id: tbZuckerAnteil
                        visible: !ctrlSpunden.checked && value > 0.0
                        precision: 0
                        value: Sud.ZuckerAnteil / app.settings.sugarFactor
                    }
                    LabelUnit {
                        visible: tbZuckerAnteil.visible
                        text: qsTr("g")
                    }
                    LabelNumber {
                        horizontalAlignment: Text.AlignHCenter
                        visible: tbZuckerAnteil.visible
                        precision: 1
                        value: Sud.JungbiermengeAbfuellen > 0.0 ? tbZuckerAnteil.value / Sud.JungbiermengeAbfuellen : 0.0
                    }
                    LabelUnit {
                        visible: tbZuckerAnteil.visible
                        text: qsTr("g/l")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Abfüllen")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        visible: !ctrlSpunden.checked
                        text: qsTr("Biermenge")
                    }
                    TextFieldVolume {
                        id: ctrlBiermenge
                        visible: !ctrlSpunden.checked
                        enabled: !page.readOnly
                        useDialog: false
                        value: Sud.erg_AbgefuellteBiermenge
                        onNewValue: (value) => Sud.erg_AbgefuellteBiermenge = value
                    }
                    LabelUnit {
                        visible: !ctrlSpunden.checked
                        text: qsTr("L")
                    }
                }
            }

            GroupBox {
                Layout.fillWidth: true
                focusPolicy: Qt.StrongFocus
                label: LabelHeader {
                    text: qsTr("Abschluss")
                }
                GridLayout {
                    anchors.fill: parent
                    columnSpacing: 16
                    columns: 3
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Abfülldatum")
                    }
                    TextFieldDateTime {
                        id: tfAbfuelldatum
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        enabled: !page.readOnly
                        date: Sud.Status >= Brauhelfer.Abgefuellt ? Sud.Abfuelldatum : new Date()
                        onNewDate: (date) => {
                            this.date = date
                        }
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Zusätzliche Kosten")
                    }
                    TextFieldNumber {
                        enabled: !page.readOnly
                        precision: 2
                        value: Sud.KostenWasserStrom
                        onNewValue: (value) => Sud.KostenWasserStrom = value
                    }
                    LabelUnit {
                        text: Qt.locale().currencySymbol()
                    }
                    LabelPrim {
                        Layout.fillWidth: true
                        text: qsTr("Gesamtkosten")
                    }
                    LabelNumber {
                        precision: 2
                        value: Sud.erg_Preis
                    }
                    LabelUnit {
                        text: Qt.locale().currencySymbol() + "/" + qsTr("L")
                    }
                    TextAreaBase {
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        opacity: enabled ? app.config.textOpacityFull : app.config.textOpacityDisabled
                        placeholderText: qsTr("Bemerkung Abfüllen")
                        textFormat: Text.RichText
                        text: Sud.BemerkungAbfuellen
                        onLinkActivated: (link) => Qt.openUrlExternally(link)
                        onTextChanged: if (activeFocus) Sud.BemerkungAbfuellen = text
                    }
                    ButtonBase {
                        id: ctrlAbgefuellt
                        Layout.columnSpan: 3
                        Layout.fillWidth: true
                        text: qsTr("Sud abgefüllt")
                        enabled: !page.readOnly
                        onClicked: abgefuellt()
                    }
                }
            }
        }
    }
}
