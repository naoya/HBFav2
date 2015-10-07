//
//  Action.js
//  ActionExtension
//
//  Created by Shinichiro Oba on 2015/04/29.
//  Copyright (c) 2015年 Shinichiro Oba. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        arguments.completionFunction();
    },
    
    finalize: function(arguments) {
        location.href = "hbfav:/entry/" + location.href;
    }
    
};
    
var ExtensionPreprocessingJS = new Action
