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

function autocomplete_input_field(input_field_selector, ajax_path) {
  $(input_field_selector).autocomplete({
    source: ajax_path,
    minLength: 2, delay: 500
  });
}

function setup_batch_certification(resetUrl, batchModeActive) {
  $('[data-units-achieved-editable]').add('#batchUpdateButtons').hide();
  $('#batchUpdateButton').add('#resetButton').button();
  $('#editModeButton').button({icons: {primary: "ui-icon-locked"}}).bind('click', function() {
    if ($(this).is(':checked')) {
      $(this).button("option", "icons", {primary: 'ui-icon-unlocked'});
    }
    else {
      $(this).button("option", "icons", {primary: 'ui-icon-locked'});
    }
    $('[data-units-achieved-read-only]').toggle();
    $('[data-units-achieved-editable]').toggle();
    $('#batchUpdateButtons').toggle();
    $('input[type="text"]').not(':hidden').first().focus();
  });
  $('#resetButton').click(function() {
    $('#batchUpdateButtons').toggle();
    window.location.href = resetUrl;
  });

  if (batchModeActive=='true') {
    $('#editModeButton').click();
    $('#editModeButton').button("option", "icons", {primary: 'ui-icon-unlocked'});
  }
}