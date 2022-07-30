# 创建基于ts+webpack的chrome插件项目

参考文档 - webpack [https://www.webpackjs.com/guides/](https://www.webpackjs.com/guides/)

参考文档 - webpack loader [https://www.webpackjs.com/loaders/](https://www.webpackjs.com/loaders/)

参考文档 - tsconfig.json [https://www.typescriptlang.org/docs/handbook/tsconfig-json.html](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html)

## 自动化创建工程

> 手动创建工程目录，然后在该目录执行以下脚本内容

```sh
# 初始化工程（不使用npm init）
echo >> package.json '{'
echo >> package.json '  "name": "crx-demo",'
echo >> package.json '  "version": "1.0.0",'
echo >> package.json '  "description": "根据Demo模板自动化创建的crx工程",'
echo >> package.json '  "private": true,'
echo >> package.json '  "scripts": {'
echo >> package.json '    "build": "webpack --config webpack.prod.js",'
echo >> package.json '    "watch": "webpack --config webpack.prod.js --watch",'
echo >> package.json '    "start": "webpack-dev-server --config webpack.dev.js --open"'
echo >> package.json '  },'
echo >> package.json '  "keywords": [],'
echo >> package.json '  "author": "Demo",'
echo >> package.json '  "license": "ISC",'
echo >> package.json '  "dependencies": {},'
echo >> package.json '  "devDependencies": {'
echo >> package.json '    "@babel/core": "^7.9.6",'
echo >> package.json '    "@babel/plugin-transform-runtime": "^7.9.6",'
echo >> package.json '    "@babel/preset-env": "^7.9.6",'
echo >> package.json '    "babel-loader": "^8.1.0",'
echo >> package.json '    "copy-webpack-plugin": "^11.0.0",'
echo >> package.json '    "ts-loader": "^9.3.1",'
echo >> package.json '    "typescript": "^4.7.4",'
echo >> package.json '    "uglifyjs-webpack-plugin": "^2.2.0",'
echo >> package.json '    "webpack": "^5.74.0",'
echo >> package.json '    "webpack-cli": "^4.10.0",'
echo >> package.json '    "webpack-dev-server": "^4.9.3",'
echo >> package.json '    "webpack-merge": "^5.8.0"'
echo >> package.json '  }'
echo >> package.json '}'



# wepack的配置文件（生产和开发环境都需要的配置）
echo >> webpack.common.js "const path = require('path');"
echo >> webpack.common.js ""
echo >> webpack.common.js "module.exports = {"
echo >> webpack.common.js "    entry: {"
echo >> webpack.common.js "        bg: './src/bg.ts',"
echo >> webpack.common.js "        page: './src/page.ts'"
echo >> webpack.common.js "    },"
echo >> webpack.common.js "    output: {"
echo >> webpack.common.js "        filename: '[name].js',"
echo >> webpack.common.js "        path: path.resolve(__dirname, 'dist', 'js')"
echo >> webpack.common.js "    },"
echo >> webpack.common.js ""
echo >> webpack.common.js "    resolve: {"
echo >> webpack.common.js "        extensions: ['.ts', '.js' ]"
echo >> webpack.common.js "    },"
echo >> webpack.common.js "    "
echo >> webpack.common.js "    module: {"
echo >> webpack.common.js "        rules: ["
echo >> webpack.common.js "            { test: /\.ts$/, loader: 'ts-loader' },"
echo >> webpack.common.js "            {"
echo >> webpack.common.js "                test: /\.js$/,"
echo >> webpack.common.js "                exclude: /(node_modules|bower_components)/,"
echo >> webpack.common.js "                use: {"
echo >> webpack.common.js "                    loader: 'babel-loader',"
echo >> webpack.common.js "                    options: {"
echo >> webpack.common.js "                        presets: ['@babel/preset-env'],"
echo >> webpack.common.js "                        plugins: ['@babel/transform-runtime']"
echo >> webpack.common.js "                    }"
echo >> webpack.common.js "                }"
echo >> webpack.common.js "            }"
echo >> webpack.common.js "        ]"
echo >> webpack.common.js "    }"
echo >> webpack.common.js "};"

# ts配置文件
echo >> tsconfig.json '{'
echo >> tsconfig.json '  "compilerOptions": {'
echo >> tsconfig.json '    "moduleResolution": "node",'
echo >> tsconfig.json '    "outDir": "./dist/",'
echo >> tsconfig.json '    "noImplicitAny": true,'
echo >> tsconfig.json '    "module": "es6",'
echo >> tsconfig.json '    "target": "es5",'
echo >> tsconfig.json '    "allowJs": true'
echo >> tsconfig.json '  }'
echo >> tsconfig.json '}'


# webpack开发环境配置文件
echo >> webpack.dev.js "const {merge} = require('webpack-merge');"
echo >> webpack.dev.js "const common = require('./webpack.common.js');"
echo >> webpack.dev.js ""
echo >> webpack.dev.js "module.exports = merge(common, {"
echo >> webpack.dev.js "    mode: 'development',"
echo >> webpack.dev.js "    devtool: 'inline-source-map',"
echo >> webpack.dev.js "    devServer: {"
echo >> webpack.dev.js "        static: './dist'"
echo >> webpack.dev.js "    }"
echo >> webpack.dev.js "});"


# webpack生产环境配置文件
echo >> webpack.prod.js "const {merge} = require('webpack-merge');"
echo >> webpack.prod.js "const UglifyJSPlugin = require('uglifyjs-webpack-plugin');"
echo >> webpack.prod.js "const common = require('./webpack.common.js');"
echo >> webpack.prod.js "const copy = require('copy-webpack-plugin')"
echo >> webpack.prod.js ""
echo >> webpack.prod.js "module.exports = merge(common, {"
echo >> webpack.prod.js "    mode: 'production',"
echo >> webpack.prod.js "    devtool: 'source-map',"
echo >> webpack.prod.js "    plugins: ["
echo >> webpack.prod.js "        new UglifyJSPlugin({"
echo >> webpack.prod.js "            sourceMap: true"
echo >> webpack.prod.js "        }),"
echo >> webpack.prod.js "        new copy({"
echo >> webpack.prod.js "            patterns: ["
echo >> webpack.prod.js "                {"
echo >> webpack.prod.js "                    from: __dirname + '/manifest.json',"
echo >> webpack.prod.js "                    to: __dirname + '/dist/manifest.json'"
echo >> webpack.prod.js "                }"
echo >> webpack.prod.js "            ]"
echo >> webpack.prod.js "        })"
echo >> webpack.prod.js "    ]"
echo >> webpack.prod.js "});"


# 创建源码目录层次
mkdir src

# 创建ts入口
echo >> src/bg.ts "console.log('bg...');"
echo >> src/page.ts "console.log('page...');"

# 创建manifest文件
echo >> manifest.json '{'
echo >> manifest.json '  "name": "Chrome Extensions",'
echo >> manifest.json '  "description": "Base Level Extension",'
echo >> manifest.json '  "version": "1.0",'
echo >> manifest.json '  "manifest_version": 2,'
echo >> manifest.json '  "background": {'
echo >> manifest.json '    "scripts": ['
echo >> manifest.json '      "js/bg.js"'
echo >> manifest.json '    ]'
echo >> manifest.json '  },'
echo >> manifest.json '  "content_scripts": ['
echo >> manifest.json '    {'
echo >> manifest.json '      "matches": ['
echo >> manifest.json '        "*://*/*"'
echo >> manifest.json '      ],'
echo >> manifest.json '      "js": ['
echo >> manifest.json '        "js/page.js"'
echo >> manifest.json '      ],'
echo >> manifest.json '      "run_at": "document_start"'
echo >> manifest.json '    }'
echo >> manifest.json '  ],'
echo >> manifest.json '  "permissions": ['
echo >> manifest.json '    "cookies",'
echo >> manifest.json '    "webRequest",'
echo >> manifest.json '    "webRequestBlocking",'
echo >> manifest.json '    "storage",'
echo >> manifest.json '    "browsingData",'
echo >> manifest.json '    "tabs",'
echo >> manifest.json '    "*://*/*"'
echo >> manifest.json '  ]'
echo >> manifest.json '}'


# 创建README.md
echo >> README.md '# 使用说明'
echo >> README.md ''
echo >> README.md '## 文件目录说明'
echo >> README.md ''
echo >> README.md '* `dist`                          -- 文件输出目录（生产环境编译后出现）'
echo >> README.md '* `dist/js/bg.js`                 -- 自动生成的js打包文件（生产环境编译后出现），注意，bg是background.js，page是content.js'
echo >> README.md '* `dist/js/bg.js.map`             -- source map文件（生产环境编译后出现），注意，bg是background.js，page是content.js'
echo >> README.md '* `src`                           -- 源码目录'
echo >> README.md '* `src/bg.ts`                     -- bg源码入口文件'
echo >> README.md '* `src/page.ts`                   -- page源码入口文件'
echo >> README.md ''
echo >> README.md '## 项目初始化'
echo >> README.md '```'
echo >> README.md 'npm install'
echo >> README.md '```'
echo >> README.md ''
echo >> README.md '### 执行生产环境的编译'
echo >> README.md '```'
echo >> README.md 'npm run build'
echo >> README.md '```'
echo >> README.md ''
echo >> README.md '### 启动开发环境自动编译和预览'
echo >> README.md '```'
echo >> README.md 'npm run start'
echo >> README.md '```'
echo >> README.md ''
echo >> README.md '### 启动生产环境自动编译'
echo >> README.md '```'
echo >> README.md 'npm run watch'
echo >> README.md '```'

# 创建.gitignore
echo >> .gitignore '.DS_Store'
echo >> .gitignore 'dist/'
echo >> .gitignore '.env.local'
echo >> .gitignore '.env.*.local'
echo >> .gitignore 'npm-debug.log*'
echo >> .gitignore 'yarn-debug.log*'
echo >> .gitignore 'yarn-error.log*'
echo >> .gitignore '.idea'
echo >> .gitignore '.vscode'
echo >> .gitignore '*.ntvs*'
echo >> .gitignore '*.njsproj'
echo >> .gitignore '*.sw?'
echo >> .gitignore '*.rsuser'
echo >> .gitignore '*.suo'
echo >> .gitignore '*.user'
echo >> .gitignore '*.userosscache'
echo >> .gitignore '*.sln.docstates'
echo >> .gitignore '*.userprefs'
echo >> .gitignore 'mono_crash.*'
echo >> .gitignore '[Dd]ebug/'
echo >> .gitignore '[Dd]ebugPublic/'
echo >> .gitignore '[Rr]elease/'
echo >> .gitignore '[Rr]eleases/'
echo >> .gitignore 'x64/'
echo >> .gitignore 'x86/'
echo >> .gitignore '[Aa][Rr][Mm]/'
echo >> .gitignore '[Aa][Rr][Mm]64/'
echo >> .gitignore 'bld/'
echo >> .gitignore '[Bb]in/'
echo >> .gitignore '[Oo]bj/'
echo >> .gitignore '[Ll]og/'
echo >> .gitignore '[Ll]ogs/'
echo >> .gitignore '.vs/'
echo >> .gitignore 'Generated\ Files/'
echo >> .gitignore '[Tt]est[Rr]esult*/'
echo >> .gitignore '[Bb]uild[Ll]og.*'
echo >> .gitignore '*.VisualState.xml'
echo >> .gitignore 'TestResult.xml'
echo >> .gitignore 'nunit-*.xml'
echo >> .gitignore '[Dd]ebugPS/'
echo >> .gitignore '[Rr]eleasePS/'
echo >> .gitignore 'dlldata.c'
echo >> .gitignore 'BenchmarkDotNet.Artifacts/'
echo >> .gitignore 'project.lock.json'
echo >> .gitignore 'project.fragment.lock.json'
echo >> .gitignore 'artifacts/'
echo >> .gitignore 'StyleCopReport.xml'
echo >> .gitignore '*_i.c'
echo >> .gitignore '*_p.c'
echo >> .gitignore '*_h.h'
echo >> .gitignore '*.ilk'
echo >> .gitignore '*.meta'
echo >> .gitignore '*.obj'
echo >> .gitignore '*.iobj'
echo >> .gitignore '*.pch'
echo >> .gitignore '*.pdb'
echo >> .gitignore '*.ipdb'
echo >> .gitignore '*.pgc'
echo >> .gitignore '*.pgd'
echo >> .gitignore '*.rsp'
echo >> .gitignore '*.sbr'
echo >> .gitignore '*.tlb'
echo >> .gitignore '*.tli'
echo >> .gitignore '*.tlh'
echo >> .gitignore '*.tmp'
echo >> .gitignore '*.tmp_proj'
echo >> .gitignore '*_wpftmp.csproj'
echo >> .gitignore '*.log'
echo >> .gitignore '*.vspscc'
echo >> .gitignore '*.vssscc'
echo >> .gitignore '.builds'
echo >> .gitignore '*.pidb'
echo >> .gitignore '*.svclog'
echo >> .gitignore '*.scc'
echo >> .gitignore '_Chutzpah*'
echo >> .gitignore 'ipch/'
echo >> .gitignore '*.aps'
echo >> .gitignore '*.ncb'
echo >> .gitignore '*.opendb'
echo >> .gitignore '*.opensdf'
echo >> .gitignore '*.sdf'
echo >> .gitignore '*.cachefile'
echo >> .gitignore '*.VC.db'
echo >> .gitignore '*.VC.VC.opendb'
echo >> .gitignore '*.psess'
echo >> .gitignore '*.vsp'
echo >> .gitignore '*.vspx'
echo >> .gitignore '*.sap'
echo >> .gitignore '*.e2e'
echo >> .gitignore '$tf/'
echo >> .gitignore '*.gpState'
echo >> .gitignore '_ReSharper*/'
echo >> .gitignore '*.[Rr]e[Ss]harper'
echo >> .gitignore '*.DotSettings.user'
echo >> .gitignore '_TeamCity*'
echo >> .gitignore '*.dotCover'
echo >> .gitignore '.axoCover/*'
echo >> .gitignore '!.axoCover/settings.json'
echo >> .gitignore '*.coverage'
echo >> .gitignore '*.coveragexml'
echo >> .gitignore '_NCrunch_*'
echo >> .gitignore '.*crunch*.local.xml'
echo >> .gitignore 'nCrunchTemp_*'
echo >> .gitignore '*.mm.*'
echo >> .gitignore 'AutoTest.Net/'
echo >> .gitignore '.sass-cache/'
echo >> .gitignore '[Ee]xpress/'
echo >> .gitignore 'publish/'
echo >> .gitignore '*.[Pp]ublish.xml'
echo >> .gitignore '*.azurePubxml'
echo >> .gitignore '*.pubxml'
echo >> .gitignore '*.publishproj'
echo >> .gitignore 'PublishScripts/'
echo >> .gitignore '*.nupkg'
echo >> .gitignore '*.snupkg'
echo >> .gitignore '**/[Pp]ackages/*'
echo >> .gitignore '!**/[Pp]ackages/build/'
echo >> .gitignore '*.nuget.props'
echo >> .gitignore '*.nuget.targets'
echo >> .gitignore 'csx/'
echo >> .gitignore '*.build.csdef'
echo >> .gitignore 'ecf/'
echo >> .gitignore 'rcf/'
echo >> .gitignore 'AppPackages/'
echo >> .gitignore 'BundleArtifacts/'
echo >> .gitignore 'Package.StoreAssociation.xml'
echo >> .gitignore '_pkginfo.txt'
echo >> .gitignore '*.appx'
echo >> .gitignore '*.appxbundle'
echo >> .gitignore '*.appxupload'
echo >> .gitignore '*.[Cc]ache'
echo >> .gitignore '!?*.[Cc]ache/'
echo >> .gitignore 'ClientBin/'
echo >> .gitignore '~$*'
echo >> .gitignore '*~'
echo >> .gitignore '*.dbmdl'
echo >> .gitignore '*.dbproj.schemaview'
echo >> .gitignore '*.jfm'
echo >> .gitignore '*.pfx'
echo >> .gitignore '*.publishsettings'
echo >> .gitignore 'orleans.codegen.cs'
echo >> .gitignore 'Generated_Code/'
echo >> .gitignore '_UpgradeReport_Files/'
echo >> .gitignore 'Backup*/'
echo >> .gitignore 'UpgradeLog*.XML'
echo >> .gitignore 'UpgradeLog*.htm'
echo >> .gitignore 'ServiceFabricBackup/'
echo >> .gitignore '*.rptproj.bak'
echo >> .gitignore '.ntvs_analysis.dat'
echo >> .gitignore 'node_modules/'
echo >> .gitignore '*.plg'
echo >> .gitignore '*.opt'
echo >> .gitignore '*.vbw'
echo >> .gitignore '*.binlog'
echo >> .gitignore '.localhistory/'
echo >> .gitignore 'cache'

```