$(function () {
  const $filterToggle = $('#filterToggle');
  const $filterCollapse = $('#filterCollapse');

  if ($filterToggle.length && $filterCollapse.length) {
    $filterToggle.on('click', function () {
      $filterCollapse.stop(true, true).slideToggle(200);
    });
  }
});
