$(function(){

  var misc = {

    init: function() {
      this.revealableList();
    },

    revealableList: function() {
      $('a.reveal-next').click(function(e){
        var $reveal = $('.revealable:hidden:first');
        $reveal.fadeIn();
        $reveal.find('input:first').focus();

        e.preventDefault();
        return false;
      });
    }
  }

  misc.init();
});