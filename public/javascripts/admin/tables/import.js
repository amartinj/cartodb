
    var create_type = 0;
    var interval = null;


    head(function(){

      $('div.geom_type span').click(function(ev){
        ev.stopPropagation();
        ev.preventDefault();
        if (!$(this).hasClass('selected')) {
          $('div.geom_type span').removeClass('selected');
          $(this).addClass('selected');
        }
      });
      
      $('div.geom_type span a').click(function(ev){
        ev.stopPropagation();
        ev.preventDefault();
        $(this).parent().trigger('click');
      });


      //Create new table
      $('a.new_table').click(function(ev){
         ev.preventDefault();
         ev.stopPropagation();
         resetUploadFile();
         $('div.create_window').show();
         $('div.mamufas').fadeIn();
         bindESC();
       });


      $('div.create_window ul li a').click(function(ev){
        ev.stopPropagation();
        ev.preventDefault();
        if (!$(this).parent().hasClass('selected') && !$(this).parent().hasClass('disabled') && !$(this).parent().is("span")) {
          $('div.create_window ul li').removeClass('selected');
          $(this).parent().addClass('selected');
          (create_type==0)?create_type++:create_type--;
        }
				
				if ($(this).closest('li').index()==1) {
					$('div.create_window span.bottom input').addClass('disabled');
				} else {
					$('div.create_window span.bottom input').removeClass('disabled');
				}
      });
      


      $('span.file input').hover(function(ev){
        $('span.file a').addClass('hover');
        $(document).css('cursor','pointer');
      },function(ev){
        $('span.file a').removeClass('hover');
        $(document).css('cursor','default');
      });

      //Uploader for the modal window
      var uploader = new qq.FileUploader({
        element: document.getElementById('uploader'),
        action: '/upload',
        params: {},
        allowedExtensions: ['csv', 'xls', 'xlsx', 'zip'],
        sizeLimit: 0, // max size
        minSizeLimit: 0, // min size
        debug: false,

        onSubmit: function(id, fileName){
          $('div.create_window ul li:eq(0)').addClass('disabled');
          $('form input[type="submit"]').addClass('disabled');
          $('span.file').addClass('uploading');     
        },
        onProgress: function(id, fileName, loaded, total){
          var percentage = loaded / total;
          $('span.progress').width((346*percentage)/1);
        },
        onComplete: function(id, fileName, responseJSON){
          createNewToFinish('',responseJSON.file_uri);
        },
        onCancel: function(id, fileName){},
        showMessage: function(message){
          $('div.select_file p').html(message);
          $('div.select_file p').addClass('error');
        }
      });

      $('form#import_file').submit(function(ev){
        ev.stopPropagation();
        ev.preventDefault();
        if (create_type==0) {
          var geom_type = $('div.geom_type span.selected a').text();
          createNewToFinish(geom_type,'');
        }
      });
    });
    

	//Uploader for the whole page (dashboard only)
	var hugeUploader = new qq.FileUploader({
		element: document.getElementById('hugeUploader'),
		action: '/upload',
		params: {},
		allowedExtensions: ['csv', 'xls', 'xlsx', 'zip'],
		sizeLimit: 0, // max size
		minSizeLimit: 0, // min size
		debug: false,
	
		onSubmit: function(id, fileName){
		  // $('div.create_window ul li:eq(0)').addClass('disabled');
		  // $('form input[type="submit"]').addClass('disabled');
		  // $('span.file').addClass('uploading');
		  resetUploadFile();
		  $('div.create_window ul li:eq(1) a').click();
		  $('#hugeUploader').hide();
      $('div.create_window').show();
      $('div.mamufas').fadeIn();
      bindESC();		  
		},
		onProgress: function(id, fileName, loaded, total){
		  var percentage = loaded / total;
		  $('span.progress').width((346*percentage)/1);
		},
		onComplete: function(id, fileName, responseJSON){
		  createNewToFinish('',responseJSON.file_uri);
		},
		onCancel: function(id, fileName){},
		showMessage: function(message){
		   $('div.select_file p').html(message);
		   $('div.select_file p').addClass('error');
		}
	});
	   


    function resetUploadFile() {
      create_type = 0;
      $('div.create_window ul li:eq(0)').removeClass('disabled');
      $('div.create_window ul li').removeClass('selected');
      $('div.create_window ul li:eq(0)').addClass('selected');
      $('div.create_window div.inner_ form').show();
      $('div.create_window div.inner_ form').css('opacity',1);
      $('div.create_window div.inner_').css('border-color','#CCCCCC');
      $('div.create_window a.close_create').removeClass('last');
      $('div.create_window div.inner_').css('height','auto');
      $('div.create_window div.inner_ span.loading').hide();
      $('div.create_window div.inner_ span.loading').css('opacity',0);
      $('form input[type="submit"]').removeClass('disabled');
      $('span.file').removeClass('uploading');
      $('span.file input[type="file"]').attr('value','');
      $('div.select_file p').text('You can import .csv, .xls and .zip files');
      $('div.select_file p').removeClass('error');
      $('span.progress').width(5);
      $('div.create_window ul li:eq(1)').removeClass('finished');
      $('div.create_window').removeClass('georeferencing');
      $('div.create_window div.inner_ span.loading p').html('It\'s not gonna be a lot of time. Just a few seconds, ok?');
      $('div.create_window div.inner_ span.loading h5').html('We are creating your table...');
    }


    function createNewToFinish (type,url) {
      $('div.create_window div.inner_').animate({borderColor:'#FFC209', height:'68px'},500);
      $('div.create_window div.inner_ form').animate({opacity:0},300,function(){
        $('div.create_window div.inner_ span.loading').show();
				$('div.create_window a.close_create').hide();
        $('div.create_window div.inner_ span.loading').animate({opacity:1},200, function(){
          var params = {}
          if (url!='') {
            params = {file:'http://'+window.location.host + url};
          } else {
            params = {the_geom_type:type}
          }
          $.ajax({
            type: "POST",
            url: global_api_url+'tables/',
            data: params,
            headers: {'cartodbclient':true},
            success: function(data, textStatus, XMLHttpRequest) {
              window.location.href = "/tables/"+data.id;
            },
            error: function(e) {
							var json = $.parseJSON(e.responseText);
              $('div.create_window div.inner_ span.loading').addClass('error');
              $('div.create_window div.inner_ span.loading p').html(json.hint);
              $('div.create_window div.inner_ span.loading h5').text(json.message);
							$('div.create_window a.close_create').show().addClass('last');
              $('div.create_window div.inner_').height(98);
            }
          });
        });
      });
      setTimeout(function(){$('div.create_window a.close_create').addClass('last');},250);
    }
    
    
    function retryImportTable() {
      $('div.create_window a.close_create').show().removeClass('last');
      $('div.create_window div.inner_').animate({borderColor:'#CCCCCC', height:'254px'},500,function(){
        $('div.create_window div.inner_').css('height','auto');
      });
      $('div.create_window ul li:eq(0)').removeClass('disabled');
      $('form input[type="submit"]').removeClass('disabled');
      $('span.file').removeClass('uploading');
      $('div.create_window div.inner_ span.loading').animate({opacity:0},300,function(){
        $('div.create_window div.inner_ span.loading').hide();
        $('div.create_window div.inner_ span.loading').removeClass('error');
        $('div.create_window div.inner_ span.loading p').html('It\'s not gonna be a lot of time. Just a few seconds, ok?');
        $('div.create_window div.inner_ span.loading h5').html('We are creating your table...');
        $('div.create_window div.inner_ form').show();
        $('div.create_window div.inner_ form').animate({opacity:1},200);
        $('div.select_file p').text('You can import .csv, .xls and .zip files');
        $('div.select_file p').removeClass('error');
      });
    }


