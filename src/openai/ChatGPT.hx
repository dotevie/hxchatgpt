package openai;

import haxe.Json;
import haxe.Http;

typedef ChatGPTOutput = {
    var id:String;
    var object:String;
    var created:Int;
    var model:String;
    var usage:ChatGPTUsage;
    var choices:Array<ChatGPTChoice>;
} 

typedef ChatGPTUsage = {
    var prompt_tokens:Int;
    var completion_tokens:Int;
    var total_tokens:Int;
}

typedef ChatGPTChoice = {
    var message:ChatGPTMessage;
    var finish_reason:String;
    var index:Int;
}

typedef ChatGPTMessage = {
    var role:String;
    var content:String;
}

typedef ChatGPTPrompt = {
    var model:String;
    var messages:Array<ChatGPTMessage>;
}

class ChatGPT {
    private var http:Http;
    private var apiKey:String;
    public var thinking:Bool = false;
    public function new(apiKey:String, ?dataCallback:ChatGPTOutput->Void, ?errorCallback:String->Void) {
        this.apiKey = apiKey;
        http = new Http('http://api.openai.com/v1/chat/completions');
        http.setHeader('Authorization', 'Bearer ' + apiKey);
        http.setHeader('Content-Type', 'application/json');
        if (dataCallback != null) {
            http.onData = (msg) -> {
                dataCallback(Json.parse(msg));
            }
        }
        if (errorCallback != null) {
            http.onError = errorCallback;
        }
    }    
    public function sendPrompt(prompt:ChatGPTPrompt, ?dataCallback:ChatGPTOutput->Void, ?errorCallback:String->Void) {
        if (dataCallback != null) {
            http.onData = (msg) -> {
                dataCallback(Json.parse(msg));
                thinking = false;
            }
        }
        if (errorCallback != null) {
            http.onError = (msg) -> {
                errorCallback(msg);
                thinking = false;
            }
        }
        http.setPostData(Json.stringify(prompt));
        thinking = true;
        http.request(true);
    }
}