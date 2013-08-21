$(function(){

  var projects = {

    init: function() {
      this.autoSuggest();
    },

    autoSuggest: function() {
      var $oas = $('input.project-auto-suggest');
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
      var $oas = $('input.project-auto-suggest');
      var str = $oas.val();

      if (str.length < 3) {
        projects.hideSuggestions();
        return;
      }
        
      else {    
        $.ajax({
          type: 'GET',
          url: '/projects',
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
              projects.clearSuggestions();
              projects.addSuggestions(data);
            });
          },
          dataType: 'json'
        });
      }
    },

    addSuggestions: function(data) {
      if (data.length > 0) {
        $.each(data, function(index, project){
          var $suggestion = $('.suggestion-template').clone()
          $suggestion.removeClass('suggestion-template').addClass('suggestion');
          $suggestion.find('.header').text(project.name);
          $suggestion.find('.subheader').text(project.organisation_names);
          $suggestion.find('.image img').attr('src', project.image_url);
          $suggestion.find('.action a').attr('href', '/projects/'+project.guid+'/request_to_join')
          $('.suggestions').append($suggestion);
        });
        
        projects.showSuggestions();
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
        projects.clearSuggestions();
      });
    }

  }

  projects.init();

});