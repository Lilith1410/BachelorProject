// Example code for electionList
var activeElections = [
  ["Äpfel und Birnen", true],
  ["Lieblingsfastfood", true],
  ["Bürgermeister", true],
  ["McD oder BK", true],
  ["Hund/Katze", false],
  ["12345 xyz", false]
];
var i;
var list = [];

//list = ["Äpfel und Birnen", "Lieblingsfastfood", "Bürgermeister", "McD oder BK", "Hund/Katze", "12345 xyz"];
var text = "<ul>";

for (i = 0; i < activeElections.length; i++) {
  list.push(activeElections[i][0]);
  text += "<li>" + "<a href=>" + list[i] + "</a>" + "</li>";
}
text += "</ul>";

document.getElementById("electionList").innerHTML = text;