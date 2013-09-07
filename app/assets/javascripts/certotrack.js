function confirm_future_date(date) {
  var today = new Date();
  var sure = true;

  if (date > today) {
    sure = confirm('Are you sure you want to enter a future date?');
  }

  if (!sure) {
    return false;
  }

  return true;
}