pragma solidity ^0.5.0;

contract Wahl {

    // Attribute
    address public owner;
    string public wahlName;
    enum wahlStatus {angelegt, aktiv, beendet}
    wahlStatus status;
    uint stimmenAnzahlProWaehler;
    mapping(address => bool) isUserValid;
    bool public userListActivated;
    mapping(address => uint) public anzahlAbgebbarerStimmen;
    mapping(string => uint)         anzahlAbgegebenerStimmen;
    mapping(address => bool) public stimmenAnWaehlerVerteilt;

    mapping(string => bool) wahlOptionVorhanden;
    string[] public wahlOptionenListe;

    //mapping(address => bool) ownerListe;

    constructor() public {
        owner = msg.sender;
        status = wahlStatus.angelegt;
        stimmenAnzahlProWaehler = 1;
    }

    // Funktionen

    /**
     * Fügt einen neuen Wähler, der abstimmen darf, zur UserListe hinzu
     * ToDo: Emit event
     * */
    function addUserToUserListe(address _user) public binWahlLeiter() returns(bool success) {
        isUserValid[_user] = true;
        return true;
    }
    /**
     * Macht Wahl privat oder öffentlich
     * */
    function activateUserList() public binWahlLeiter() wahlIstAngelegt(status) returns (bool success){
        userListActivated = true;
        return true;
    }

    /**
     * Wahlleiter kann bei angelegter Wahl Stimmenanzahl festlegen
     * Todo: Emit event
     */
    function setStimmenAnzahlProWaehler(uint _stimmenAnzahlProWaehler) public binWahlLeiter() wahlIstAngelegt(status) returns (bool success){
        stimmenAnzahlProWaehler = _stimmenAnzahlProWaehler;
        return true;
    }

    /**
     * Hinzufügen einer Wahloption in die WahlOptionenListe durch den Wahlleiter bei angelegter Wahl
     * ToDo: emit event
     * */
    function addWahlOption(string memory _option) public binWahlLeiter() wahlIstAngelegt(status) returns(bool success) {
        wahlOptionenListe.push(_option);
        wahlOptionVorhanden[_option] = true;
        return true;
    }

    /**
     * setzt den Wahlnamen fest
     * ToDo: emit event
     * ToDo: nur admin darf namen festlegen
     **/
    function setWahlName(string memory _name) public binWahlLeiter() wahlIstAngelegt(status) returns(bool success) {
        wahlName = _name;
        emit changedName(msg.sender, wahlName);
        return true;
    }

    /**
     * startet die Wahl, sofern der Aufrufer Admin ist und der Status der Wahl auf angelegt steht
     * ToDo: Emit event
     * */
    function starteWahl() public binWahlLeiter() wahlIstAngelegt(status) returns(bool success)  {
        status = wahlStatus.aktiv;
        emit changedStatus(msg.sender, status);
        return true;
    }

    /**
     * beendet die Wahl, sodern der Aufrufer Wahlleiter ist und die Wahl den status aktiv hat
     * */
    function beendeWahl() public binWahlLeiter() wahlIstAktiv(status) returns(bool success)  {
        status = wahlStatus.beendet;
        emit changedStatus(msg.sender, status);
        return true;
    }

    /**
     *  getter for Wahlstatus
     *  Benötigt, da enums nicht public seien können.
     */

    function getWahlStatus() public view returns(wahlStatus status_){
        return status;
    }

    /**
     * Wahl-Methoden
     *
     * */
    function stimmenInitialisieren() private waehlenErlaubt() wahlIstAktiv(status) returns (bool success){
        require(stimmenAnWaehlerVerteilt[msg.sender]==false);
        stimmenAnWaehlerVerteilt[msg.sender] = true;
        anzahlAbgebbarerStimmen[msg.sender] = stimmenAnzahlProWaehler;
        return true;
    }

    function stimmeAbgegeben(string memory _wahloption) public waehlenErlaubt() wahlIstAktiv(status) returns (bool success){
        require(wahlOptionVorhanden[_wahloption]);
        stimmenInitialisieren();
        require(anzahlAbgebbarerStimmen[msg.sender]>=1);
        anzahlAbgebbarerStimmen[msg.sender] -= 1;
        anzahlAbgegebenerStimmen[_wahloption] += 1;
        return true;
    }

    function mehrereStimmenAbgeben(string memory _wahloption, uint _anzahlStimmen) public waehlenErlaubt() wahlIstAktiv(status) returns (bool success){
        require(wahlOptionVorhanden[_wahloption]);
        stimmenInitialisieren();
        require(anzahlAbgebbarerStimmen[msg.sender]>=_anzahlStimmen);
        anzahlAbgebbarerStimmen[msg.sender] -= _anzahlStimmen;
        anzahlAbgegebenerStimmen[_wahloption] += _anzahlStimmen;
        return true;
    }

    /**
     * Anzahl der abgegebenen Stimmen für eine Wahloption auslesen.
     * */
    function getWahlergebnis(string memory _wahloption) public view returns (uint stimmen){
        require(wahlOptionVorhanden[_wahloption]);
        return anzahlAbgegebenerStimmen[_wahloption];
    }

    // modifier
    modifier binWahlLeiter() {
        require(owner == msg.sender);
        _;
    }

    modifier wahlIstAngelegt(wahlStatus _status) {
        require(_status == wahlStatus.angelegt);
        _;
    }

    modifier wahlIstAktiv(wahlStatus _status) {
        require(_status == wahlStatus.aktiv);
        _;
    }

    modifier waehlenErlaubt() {
        require(isUserValid[msg.sender] || !userListActivated);
        _;
    }

    // events
    event changedStatus(address _by, wahlStatus _toStatus);
    event changedName(address _by, string _toWahlName);

}

contract UserVerzeichnis {


    // Attribute
    mapping(address => wahlListe[]) public userWahlenListe;
    mapping(string => address) aliasListeMapping;

    struct wahlListe {
        address wLAddress;
    }

    // Konstruktor
    constructor() public {}

    /**
     * Getter für aliasListeMappingelement (bzw. dessen Value) .
     * Benötigt, da ein Mapping mit einem string nicht public sein kann.
     * */
     function getAddressByAlias(string memory _alias) public view returns(address address_){
         return aliasListeMapping[_alias];
     }


    /**
     * Füge Alias und Alias-Addresse zur AliasListe hinzu
     * ToDo: emit event
     * ToDo: modifier
     * */
    function addToAliasListeMapping(string memory _alias, address _address) public returns(bool success) {
        aliasListeMapping[_alias] = _address;
        return true;
    }

    /**
     * Füge zu einem UserAdresse-Schlüssel eine Wahl-Addresse in das bestehende Array von "hier darf
     * ich wählen" Liste Hinzu
     * ToDo: emit event
     * ToDo: modifier
     * */
    function addToUserWahlenListe(address _user, address _wahlAddresse) public returns(bool success) {
        wahlListe memory wl = wahlListe(_wahlAddresse);
        wl.wLAddress = _wahlAddresse;
        userWahlenListe[_user].push(wl);
        return true;
    }
}

contract WahlVerzeichnis {

    // Attribute 

    mapping(uint256 => address) public inviteCodeAddressListe;

    // Konstruktor
    constructor() public {
    }

    // Funktion

    /**
     * Füge einen Code und eine Wahl-Addresse zur inviteCodeAddressListe Hinzu
     * ToDo: emit event
     * ToDo: modifier
     **/
    function addToInviteCodeAddressList(uint256 _inviteCode, address _wahlAddresse) public returns(bool success) {
        inviteCodeAddressListe[_inviteCode] = _wahlAddresse;
        return true;
    }
}