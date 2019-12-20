Pipeline Utility Steps https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/#readproperties-read-properties-from-files-in-the-workspace-or-text

readProperties: Read properties from files in the workspace or text.
Reads a file in the current working directory or a String as a plain text Java Properties file. The returned object is a normal Map with String keys. The map can also be pre loaded with default values before reading/parsing the data.

Fields:
file: Optional path to a file in the workspace to read the properties from. These are added to the resulting map after the defaults and so will overwrite any key/value pairs already present.
text: An Optional String containing properties formatted data. These are added to the resulting map after file and so will overwrite any key/value pairs already present.
defaults: An Optional Map containing default key/values. These are added to the resulting map first.
interpolate: Flag to indicate if the properties should be interpolated or not. In case of error or cycling dependencies, the original properties will be returned.
Example:


        def d = [test: 'Default', something: 'Default', other: 'Default']
        def props = readProperties defaults: d, file: 'dir/my.properties', text: 'other=Override'
        assert props['test'] == 'One'
        assert props['something'] == 'Default'
        assert props.something == 'Default'
        assert props.other == 'Override'
        
Example with interpolation:
        def props = readProperties interpolate: true, file: 'test.properties'
        assert props.url = 'http://localhost'
        assert props.resource = 'README.txt'
        // if fullUrl is defined to ${url}/${resource} then it should evaluate to http://localhost/README.txt
        assert props.fullUrl = 'http://localhost/README.txt'
        
defaults (optional)
Nested Choice of Objects
file (optional)
Type: String
interpolate (optional)
Type: boolean
text (optional)
Type: String