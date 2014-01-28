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

          var buttonHref = $suggestion.find('.action a').attr('href');
          $suggestion.find('.action a').attr('href', buttonHref.replace(':organisation_id', org.guid));

          $suggestion.find('.image img').attr('src', org.image_url);

          if($.inArray( org.uri, current_organisation_uris ) > -1 ){
            $suggestion.addClass("current");
            $suggestion.find('.messages').text("(already a member)");
          }

          var anchor = $suggestion.find('.action a');

          if (anchor.attr('href') == '#') {
            $suggestion.click(function(ev) {
              that.clearSuggestions();
              $('.remove-if-org').remove();
              $('.change-email-help-on-org-select').html("Add your contact's name and email address if you know it, to help " + org.name + " process your invitation.");

              anchor.text('Cancel Invite').click(function(ev) {
                window.location = window.location;
                ev.preventDefault();
              });
              
              $('#invited-organisation-id').val(org.guid);
              $('.suggestions').append($suggestion);
              ev.preventDefault();
            });
          }
          
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
