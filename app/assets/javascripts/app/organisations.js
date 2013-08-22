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

      if (str.length < 3) {
        organisations.hideSuggestions();
        return;
      }

      else {
        $.ajax({
          type: 'GET',
          url: '/organisations',
          data: {
            q: str
          },
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
      if (data.length > 0) {
        $.each(data, function(index, org){
          var $suggestion = $('.suggestion-template').clone()
          $suggestion.removeClass('suggestion-template').addClass('suggestion');
          $suggestion.find('.header').text(org.name);
          $suggestion.find('.subheader').text('The address will appear here');
          $suggestion.find('.image img').attr('src', org.image_url);
          $suggestion.find('.action a').attr('href', '#'+org.guid)
          $('.suggestions').append($suggestion);
        });

        organisations.wireUpRequestButtons();
        organisations.showSuggestions();
      }
    },

    wireUpRequestButtons: function() {
      $('.suggestions .action a').click(function(e) {
        e.preventDefault();
        var target = $(e.target);
        var href = target.attr('href');
        var guid = href.substring(1);

        var messages = target.closest('.suggestion').find('.messages');

        messages.removeClass('error');
        messages.html('working...');

        $.ajax({
          url: '/organisations/'+guid+'/request_to_join',
          dataType: 'json',
          success: function(data, textStatus, jqXHR) {
            if (data.errorMessage) {
              messages.addClass('error');
              messages.html(data.errorMessage);
            } else {
              window.location= '/user'; // redirect to dashboard.
            }
          },
          error: function(jqXHR, textStatus, errorThrown) {
            messages.addClass('error');
            messages.html('Something Went Wrong');
          }
        });
      });
      // '/organisations/'+org.guid+'/request_to_join'
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