$(function () {

  $("form.delete").on("submit", function (event) {
    event.preventDefault();
    event.stopPropagation();

    var ok = confirm("Are you sure you want to irreversibly delete?");
    if (ok) {
      var form = $(this);

      var request = $.ajax({
        url: form.attr("action"),
        method: form.attr("method")
      });

      request.done(function (data, _textStatus, jqXHR) {
        if (jqXHR.status === 204) {
          form.parent("li").remove();
        } else if (jqXHR.status === 200) {
          document.location = data;
        }
      });
    }
  });

});