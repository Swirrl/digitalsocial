$(function(){

  var dashboard = {

    init: function() {
      this.revealNatures();
    },

    revealNatures: function() {
      $('.respondables .project_request .accept, .respondables .project_invite .accept').click(function(e){

        var $respondable = $(this).parents('.respondable');
        $respondable.find('.action').fadeOut('fast', function(){
          $respondable.find('.natures').fadeIn('fast');
        })

        e.preventDefault();
      })
    }

  }

  dashboard.init();

});