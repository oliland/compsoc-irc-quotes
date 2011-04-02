$(function() {
  $(".vote").click(function() {
    button = $(this)

    var data = {
      "quote": button.attr("quote"),
      "direction": button.attr("direction")
    }

    $.post("/vote", data, function(data) {
      numVotes = $("#quote_" + button.attr("quote") + "_votes");
      console.log(data);
      numVotes.html(data);
      /*button.toggleClass("on");*/
    });

  });
});
