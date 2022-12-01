$(function () {

  $("form.delete").on("submit", function (event) {
    event.preventDefault();
    event.stopPropagation();

    var ok = confirm("Are you sure you want to irreversibly delete?");
    if (ok) {
      this.submit();
    }
  });

});