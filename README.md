# i18next json file translator
A Simple ruby script to translate json files.  
Doesn't translate i18next variables `{{my-var}}`

## How to use
* copy the file `env.rb.example` into `env.rb` don't forget to put your DeepL API key inside
* install dependencies `bundle install`
* usage: 
    ```bash
    ruby main.rb <input_json_file> <from_language> <result_language> [<output_file>]
    ```
  If output file is omitted the result will be printed on your terminal.