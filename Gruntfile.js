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
      output: "build",
      pkg: grunt.file.readJSON('package.json'),
      banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %>\n'+
                '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;'+
                ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',      
      jshint: {
        all: [
          'Gruntfile.js', 'src/assets/js/*.js'          
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
        }       
      },
      // clean ouput directory
      clean: {
        output: ['<%= output %>/*']
      },
      // copy couchapp & static files
      copy: {
        xquery: {
          files: [
            { dest: "<%= output %>/", cwd: "src/", src: ['app/**', 'test/**'], expand: true} // static xquery content, no compression needed            
          ]
        },
        tests: {
          files: [
            { dest: "<%= output %>/", cwd: "src/", src: ['app/**', 'test/**'], expand: true}  // static tests content, no compression needed
          ]
        },
        assets: {
          files: [
            { dest: "<%= output %>/assets/img/", cwd: "src/assets/images/", src: ['*'], expand: true }, // logo & oecd stuff (will be converted to sprite at some point...)
            { dest: "<%= output %>/assets/img/", cwd: "components/bootstrap/img/", src: ['*'], expand: true }, // bootstrap img            
            { dest: "<%= output %>/assets/css/images/", cwd: "components/jquery-ui/themes/cupertino/images/", src: ['*'], expand: true } // jquery ui img -- path relative to css (../images)
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
          src: ['src/assets/js/map/*.js', 'src/assets/js/home-*.js'],
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
          banner: '<%= banner %>',
          keepSpecialComments: 0,          
          removeEmpty: true
        },
        assets_css: {          
          files:  [
            { dest: "<%= output %>/assets/css", cwd: "<%= output %>/assets/css", src: ['*.css'], expand: true }            
          ]
        }
      },
      /**
      * cachebusters.xml generation
      **/
      cachebuster: {
        options: {          
          basedir: '<%= output %>', // part to strip off the local paths
          formatter: function(hashes) {
              var output = '<!--\n' +
                  ' * GENERATED FILE, DO NOT EDIT. This file is simply a collection of generated hashes for static assets in \n' +
                  ' * the project. It is generated by grunt, see Gruntfile.js for details.\n' +
                  ' -->\n';
              output += '<cachebusters>\n';
              for (var filename in hashes) {
                  output += '\t<asset path="/' + filename.replace(/\\/ig, '/') + '">' + hashes[filename] + '</asset>\n';
              }
              output += '</cachebusters>\n';
              return output;
          }
        },
        assets: {
          files: {
            '<%= output %>/app/cachebusters.xml': ['<%= output %>/assets/js/*.js','<%= output %>/assets/css/*.css']
          }
        }
      },
      sftp: {
        app: {
          files: {
            "./": "<%= output %>/**"
          },
          options: (grunt.file.isFile('sftp.json')) ? 
              grunt.util._.extend( grunt.file.readJSON('sftp.json'), {
                srcBasePath: '<%= output %>/'
              })
              : {}          
        }
      },      
      watch: {
        files: ['Gruntfile.js', 'src/**'],
        tasks: 'dev'
      }  
    });

    // These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-jshint'); // jshint
    grunt.loadNpmTasks('grunt-contrib-concat'); // concat
    grunt.loadNpmTasks('grunt-contrib-uglify'); // min
    grunt.loadNpmTasks('grunt-contrib-watch'); // watch
    grunt.loadNpmTasks('grunt-contrib-copy'); // copy
    grunt.loadNpmTasks('grunt-contrib-cssmin'); // cssmin
    grunt.loadNpmTasks('grunt-contrib-less'); // less
    grunt.loadNpmTasks('grunt-contrib-clean'); // clean
    grunt.loadNpmTasks('grunt-cachebuster'); // cachebuster

    // used only in DEV
    grunt.loadNpmTasks('grunt-ssh');
    
    // Wrapper tasks
    // base build
    grunt.registerTask('default', ['build']);
    grunt.registerTask('build', ['jshint', 'copy', 'concat', 'less', 'cachebuster']);

    // Full build (clean first, then build and minify)
    grunt.registerTask('full', ['clean', 'build', 'min']);
    
    // No clean nor min and but sftp after in dev target
    grunt.registerTask('dev', ['build', 'sftp']);

    // minification step (compact css & js) then recalculate cachebusters!
    grunt.registerTask('min', ['cssmin', 'uglify', 'cachebuster']);

  };

