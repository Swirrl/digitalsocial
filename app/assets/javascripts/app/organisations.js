$(function(){

  var organisations = {

    init: function() {
      this.autoSuggest();
    },

    autoSuggest: function() {
      var $oas = $('input.organisation-auto-suggest');
      var _this = this;

      if ($oas.length) {

        $oas.keyup(function(e) {
          clearTimeout($.data(this, 'timer'));
          if (e.keyCode == 13)
            _this.getSuggestions(true);
          else
            $(this).data('timer', setTimeout(_this.getSuggestions, 500));
          
          e.preventDefault();
          return false;
        });

      }
    },

    getSuggestions: function() {
      var $oas = $('input.organisation-auto-suggest');
      var str = $oas.val();
      //if (!force && str.length < 3) return;

      if (str.length < 3) return;
        
      else {    
        $.ajax({
          type: 'GET',
          url: '/organisations',
          data: {
            q: str
          },
          dataType: 'JSON',
          beforeSend: function(){
            $oas.addClass('loading');
          },
          complete: function(){
            $oas.removeClass('loading');
          },
          error: function(){
            alert('error');
          },
          success: function(data){
            console.log(data);

            // });
          },
          dataType: 'json'
        });
      }
    }

  }

  organisations.init();

});