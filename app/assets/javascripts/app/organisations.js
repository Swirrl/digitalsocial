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

      if (str.length < 2) {
        organisations.hideSuggestions();
        return;
      }

      else {
        var data = {
          q: str
        }

        if ($("#project-id").length) {
          data.p = $("#project-id").val();
        }

        $.ajax({
          type: 'GET',
          url: '/organisations',
          data: data,
          beforeSend: function(){
            $oas.addClass('loading');
          },
          complete: function(){
            $oas.removeClass('loading');
          },
          error: function(){
            
          },
          success: function(data){
            $('.suggestions').slideUp('fast', function(){
              organisations.clearSuggestions();
              organisations.addSuggestions(data);
            });
          },
          dataType: 'json'
        });
      }
    },

    addSuggestions: function(data) {
      var that = this;
      if (data.organisations && data.organisations.length > 0) {

        var orgs = data.organisations;
        var current_organisation_uris = data.current_organisation_uris;

        $.each(orgs, function(index, org){
          var $suggestion = $('.suggestion-template').clone();
          $suggestion.removeClass('suggestion-template').addClass('suggestion');
          $suggestion.find('.header').text(org.name);
          if(org.address) {
            $suggestion.find('.subheader').text(org.address);
          } else {
            $suggestion.find('.subheader').text('Address not supplied.');
          }

          $suggestion.find('.image img').attr('src', org.image_url);

          if($.inArray( org.uri, current_organisation_uris ) > -1 ){
            $suggestion.addClass("current");
            $suggestion.find('.messages').text("(already a member)");
          }

          var anchor = $suggestion.find('.action a');
          var urlTemplate = anchor.attr('href');
          anchor.attr('href', urlTemplate.replace(':organisation_id', org.guid));
          
          $suggestion.click(function(ev) {
            that.clearSuggestions();
            $('.remove-if-org').remove();

            anchor.text('Remove').click(function(ev) {
              window.location = window.location;
              ev.preventDefault();
            });
            
            $('#organisation-id').val(org.guid);
            $('.suggestions').append($suggestion);
            ev.preventDefault();
          });
          
          $('.suggestions').append($suggestion);
        });

       // organisations.wireUpRequestButtons();
        organisations.showSuggestions();
      }
    },


    clearSuggestions: function() {
      $('.suggestion').remove();
    },

    showSuggestions: function() {
      $('.suggestions').slideDown('fast');
    },

    hideSuggestions: function() {
      $('.suggestions').slideUp('fast', function(){
        organisations.clearSuggestions();
      });
    }

  }

  organisations.init();

});
