# Configuracion para automatizar los estandares de codificacion en PHP

##### Requisitos
Tener instaldo `composer`.

1. Instalar `php-cs-fixer` de manera global con:
    `composer global require friendsofphp/php-cs-fixer`
    o 
    `./composer.phar global require friendsofphp/php-cs-fixer`

2. Exportar la variable de entorno:
    `export PATH="$PATH:$HOME/.composer/vendor/bin"`

3. Ejecutar `vim ~/.php_cs.dist`, el editor puede variar(vi, nano, gedit, etc)

4. Dentro del archivo creado, copiar y pegar el siguiente codigo:
    ````
    <?php

        $finder = PhpCsFixer\Finder::create()
            ->notPath('bootstrap/cache')
            ->notPath('storage')
            ->notPath('vendor')
            ->in(__DIR__)
            ->name('*.php')
            ->notName('*.blade.php')
            ->ignoreDotFiles(true)
            ->ignoreVCS(true);

        $rules = [
            '@Symfony' => true,
            '@PSR2' => true,
            'heredoc_to_nowdoc' => true,
            'no_multiline_whitespace_before_semicolons' => true,
            'no_useless_return' => true,
            'not_operator_with_successor_space' => true,
            'ordered_imports' => true,
            'phpdoc_order' => true,
        ];

        return PhpCsFixer\Config::create()
            ->setUsingCache(false)
            ->setRules($rules)
            ->setFinder($finder);
    ````
    
5. Ir a la carpeta del proyecto donde estamos trabajando, si `git` no se ha inicializado ejecutar `git init`.

6. Ejecutar `cp .git/hooks/pre-commit-sample .git/hooks/pre-commit`

7. Editar el archivo previamenete creado con `vim .git/hooks/pre-commit`

8. Reemplazar el codigo existente con el siguiente:
    ````
    #!/usr/bin/env php
    <?php
        // where your project root directory is located
        $PROJECT_ROOT = dirname(__DIR__, 2).'/';
        // PHP executable binary
        $PHP_BIN = exec('which php');
        // php-cs-fixer executable
        $PHPCSFIXER_BIN = 'php-cs-fixer';
        // php-cs-fixer config file
        $PHPCSFIXER_CONFIG_FILE = getenv('HOME').'/.php_cs.dist';
        // php-cs-fixer.phar will fix files whose names fit this regular expression
        $PHP_CS_FIXER_FILE_PATTERN = '/\.(php|twig|yml)$/';

        $options = getopt('i', array('install'));
        if (isset($options['i']) || isset($options['install'])) {
            install();
            echo "Git hook successfully installed" . PHP_EOL;
            exit(1);
        }

        function install() {
            global $PROJECT_ROOT;
            //create link
            $link = $PROJECT_ROOT . '.git/hooks/pre-commit';
            @unlink($link);
            exec(sprintf('ln -s %s %s', __FILE__, $link));
        }

        function getStashedFiles($filePattern) {
            $against = exec('git rev-parse --verify HEAD') ?: 'HEAD';
            $files = array();
            exec('git diff-index --name-only --cached --diff-filter=ACMR ' . $against . ' --', $files);

            return array_filter($files, function($file) use ($filePattern) {
                return (bool) preg_match($filePattern, $file);
            });
        }

        function runPhpLint() {
            global $PHP_BIN, $PROJECT_ROOT, $PHP_CS_FIXER_FILE_PATTERN;

            $filesWithErrors = array();
            foreach (getStashedFiles($PHP_CS_FIXER_FILE_PATTERN) as $file) {
                $output = '';
                $returnCode = null;
                exec(sprintf('%s -l %s 2>/dev/null', $PHP_BIN, $PROJECT_ROOT . $file), $output, $returnCode);
                if ($returnCode) {
                    $filesWithErrors[] = $file;
                }
            }

            return $filesWithErrors;
        }

        function runPhpCsFixer() {
            global $PHPCSFIXER_BIN, $PHP_CS_FIXER_FILE_PATTERN, $PROJECT_ROOT, $PHPCSFIXER_CONFIG_FILE;

            $changedFiles = array();
            foreach (getStashedFiles($PHP_CS_FIXER_FILE_PATTERN) as $file) {
                $output = '';
                $returnCode = null;
                exec(sprintf('%s fix %s --config=%s', $PHPCSFIXER_BIN, $PROJECT_ROOT . $file, $PHPCSFIXER_CONFIG_FILE), $output, $returnCode);
                if ($returnCode) {
                    $changedFiles[] = $file;
                }
            }

            return $changedFiles;
        }

        $phpSyntaxErrors = runPhpLint();
        $phpCSErrors = runPhpCsFixer();

        if ($phpSyntaxErrors) {
            echo "\e[31mPHP syntax errors were found in next files:" . PHP_EOL;

            foreach ($phpSyntaxErrors as $error) {
                echo "\t".$error . PHP_EOL;
            }
        }

        if ($phpCSErrors) {
            echo "\e[36mIncorrect coding standards were detected and fixed." . PHP_EOL;
            echo "Please stash changes and run commit again." . PHP_EOL;
            echo "List of changed files:" . PHP_EOL;

            foreach ($phpCSErrors as $error) {
                echo "\t".$error . PHP_EOL;
            }
        }

        exit($phpSyntaxErrors || $phpCSErrors ? 1 : 0);
    ````


10. Trabajar en el repositorio normalmente, el funcionamiento de esta configuracion se basa en estandares de Symfony, PSR1 y PSR2 las cuales se encargan de analizar el codigo y corregirlo para mantener el estandar de acuerdo a las mejores practicas de PHP:
    - Al tener los cambios en el repositorio local y listos para ser enviados al repositorio remoto ejecutar el comando `git add` y `git commit` con normalidad, el proceso puede tardar mas debido al analisis que se estara ejecutando en segundo plano. En consola se mostrara el resultado del analisis y correcciones hechas.

### Nota    
Los pasos 6, 7 y 8 deben hacer en cada proyecto(se esta trabajando en una automatizacion)

###### Agustin Espinoza | Version 1.0
