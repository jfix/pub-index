 /*jshint node:true*/
 /*globals */

 /*
 * grunt file for PubIndex
 * http://publications.oecd.org/
 *
 * Copyright (c) 2013 "OECD PAC/PS"
 */

  module.exports = function(grunt) {

    'use strict'; 

    // read config from json file
    //var config = grunt.file.readJSON('grunt-variables.json');


    // Project configuration.
    grunt.initConfig({
      output: "_build",
      pkg: grunt.file.readJSON('package.json'),
      banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %>\n'+
                '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;'+
                ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',      
      jshint: {
        all: [
          'Gruntfile.js'          
        ],        
        options: {
          //curly: true, // allow single statements in conditionals
          eqeqeq: true,
          immed: true,
          latedef: true,
          newcap: true,
          noarg: true,
          sub: true,
          undef: true,
          boss: true,
          eqnull: true,
          browser: true
        },
        globals: {}
      },
      // clean ouput directory
      clean: {
        output: ['<%= output %>/*']
      },
      // copy couchapp & static files
      copy: {
        xquery: {
          files: [
            { dest: "<%= output %>/", cwd: "src/", src: ['app/**', 'test/**'], expand: true},  // static content, no compression needed
            { dest: "<%= output %>/assets/img/", cwd: "src/assets/images/", src: ['*'], expand: true }, // logo & oecd stuff (will be converted to sprite at some point...)
            { dest: "<%= output %>/assets/img/", cwd: "components/bootstrap/img/", src: ['*'], expand: true }, // bootstrap img            
            { dest: "<%= output %>/assets/css/images/", cwd: "components/jquery-ui/themes/cupertino/images/", src: ['*'], expand: true } // jquery ui img            
          ]
        }
      },      
      concat: {
        options: {
          stripBanners: true,
          banner: '<%= banner %>'
        },
        vendor: {
          src: ['components/jquery/jquery.min.js',
                // bootstrap
                'components/bootstrap/js/bootstrap-transition.js',
                'components/bootstrap/js/bootstrap-alert.js',
                'components/bootstrap/js/bootstrap-button.js',
                'components/bootstrap/js/bootstrap-carousel.js',
                'components/bootstrap/js/bootstrap-collapse.js',
                'components/bootstrap/js/bootstrap-dropdown.js',
                // 'components/bootstrap/js/bootstrap-modal.js',
                // 'components/bootstrap/js/bootstrap-tooltip.js',
                // 'components/bootstrap/js/bootstrap-popover.js',
                // 'components/bootstrap/js/bootstrap-scrollspy.js',
                'components/bootstrap/js/bootstrap-tab.js',
                'components/bootstrap/js/bootstrap-typeahead.js',
                // jQuery UI widgets (slider & datepicker)
                'components/jquery-ui/ui/jquery.ui.core.js',
                'components/jquery-ui/ui/jquery.ui.widget.js',
                'components/jquery-ui/ui/jquery.ui.mouse.js',                
                'components/jquery-ui/ui/jquery.ui.slider.js',
                'components/jquery-ui/ui/jquery.ui.datepicker.js'
                ],
          dest: '<%= output %>/assets/js/vendor.js'
        },
        app: {
          src: ['src/assets/js/app-*.js', 'src/assets/js/oecd-*.js'],
          dest: '<%= output %>/assets/js/app.js'
        },
        home: {
          src: ['src/assets/js/home-*.js'],
          dest: '<%= output %>/assets/js/home.js'
        }        
      },      
      less: {        
        websitestyles: {
          files: {
            "<%= output %>/assets/css/site.css": [
              "src/assets/less/_site.less", // main less file, importing all others
              "components/jquery-ui/themes/cupertino/jquery-ui.min.css" //Jquerui UI does not provide less... nor per item styles...
            ]
          }
        }
      },
      uglify: { //JS Minification
        options: {
          stripBanners: true,
          banner: '<%= banner %>'
        },
        assets_js: {
          files: [
            { dest: "<%= output %>/assets/js", cwd: "<%= output %>/assets/js", src: ['*.js'], expand: true }
          ] 
        }
      },      
      cssmin: { // CSS Minify Task
        options: {
          keepSpecialComments: 0,          
          removeEmpty: true
        },
        assets_css: {          
          files:  [
            { dest: "<%= output %>/assets/css", cwd: "<%= output %>/assets/css", src: ['*.css'], expand: true }            
          ]
        }
      },
      sftp: {
        app: {
          files: {
            "./": "<%= output %>/**"
          },
          options: {            
            host: 'vm-ml',
            username: 'teddy',
            password: 'boulogne92',
            path: '/opt/PublicationIndex/',
            srcBasePath: '<%= output %>/',
            createDirectories: true
          }
        }
      },
      /*sshexec: {
        test: {
          command: 'uptime',
          options: {
            host: 'vm-ml',
            username: 'teddy',
            password: 'boulogne92'
          }
        }
      },*/
      watch: {
        files: ['Gruntfile.js', 'src/**'],
        tasks: 'default'
      }  
    });

  /*
    // define task to make sprites with Glue
    grunt.registerTask('sprites', 'Making sprite file', function() {
        var exec = require('child_process').exec;
        var _ = grunt.util._;

        // this requires glue... get http://portablepython.com/wiki/PortablePython2.7.3.2 + /Scripts/easy_install.exe glue
        if(!config.gluePath || !grunt.file.exists(config.gluePath))
          grunt.log.write('Glue is not available, skipping...').ok();

        var glueArgs = ['sprites', // folder to look in in cwd
                       //'--debug',
                       '--img="../../'+output+'/assets/img"', // where to write the icon.png file
                       '--css=.', // less file goes to current path
                       '--less', // we are LESSing our stylesheets here, no less ^^!
                       '--crop', // crop whitespace arout icons
                       '--recursive', // reccursive on folder (make ony one png)
                       '--cachebuster', // appends a ?hash after image name
                       '--url="../img/"',
                       '--sprite-namespace=""',
                       '--namespace="ac"', // start css classes by ac-<filename>
                       "--global-template=%(all_classes)s{background-image:url('%(sprite_url)s');background-repeat:no-repeat;display:inline-block;vertical-align:middle}" // force inline and block display
                       ];

        // Tell grunt the task is async
        var cb = this.async();

        var cmd = ["\""+config.gluePath+"\""].concat(glueArgs).join(' ');
        var cp = exec(cmd, {
          cwd: './_attachments/less'
        }, function(err, result, code) {          
          if(err) {
            grunt.log.error(err);            
          } else {
            grunt.log.writeln(result);
            grunt.log.write('Making sprites...').ok();
          }          
          cb();
        });
        
    });
 */

    // These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-jshint'); // jshint
    grunt.loadNpmTasks('grunt-contrib-concat'); // concat
    grunt.loadNpmTasks('grunt-contrib-uglify'); // min
    grunt.loadNpmTasks('grunt-contrib-watch'); // watch
    grunt.loadNpmTasks('grunt-contrib-copy'); // copy
    grunt.loadNpmTasks('grunt-contrib-cssmin'); // cssmin
    grunt.loadNpmTasks('grunt-contrib-less'); // less
    grunt.loadNpmTasks('grunt-contrib-clean'); // clean
    grunt.loadNpmTasks('grunt-ssh');
    
    // Wrapper tasks
    grunt.registerTask('default', ['copy', 'concat', 'less', 'sftp']);
    //grunt.registerTask('full', ['clean', 'copy', 'concat', 'sprites', 'less', 'couchapp']);
    grunt.registerTask('min', ['cssmin', 'uglify']);
    //grunt.registerTask('full-with-min', ['clean', 'copy', 'concat', 'sprites', 'less', 'min', 'couchapp']);

  };

