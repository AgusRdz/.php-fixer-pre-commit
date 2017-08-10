# Apply PSR-1 and PSR-2 with a simple commit

##### Let's do it

1. Execute the following command in your terminal:
`git clone https://github.com/AgusRdz/php-fixer-pre-commit.git`
This folder contains 3 essential files:
- `installer.sh`: Before running them if you like, you can check the configuration process in detail.
- `config-rules.dist`: This is the rule file to carry out the standardization with PSR1 and PSR2.
- `pre-commit`: Instructions that will be executed to validate and apply the rules before the end of the commit.

2. Access the folder with:
`cd php-fixer-pre-commit`
3. Execute the installer.sh file as superuser
`sudo bash installer.sh`
4. Access the repository you want to apply these standards, for example:
```
cd ~/Documents/Projects/my-awesome-project-php
git init #if it has not been initialized
```
5. Execute the following command
`pre-commit-init`

##### How it works?

Before the commit we can have code like the following:
```
<?php namespace App;
use XDependency;
use ADependency;
use YDependency;
use BDependency;

class MyClass{
  public function calculatePrice () {
      $a = 9 ;
     $b= 10 ;
   return $a + $b;
  }
    }
?>
```

And then the code will have been applied PSR1 and PSR2, having a code like the following.

```
<?php

namespace App;

use ADependency;
use BDependency;
use XDependency;
use YDependency;

class MyClass
{
    public function calculatePrice()
    {
        $a = 9;
        $b = 10;

        return $a + $b;
    }
}
```

###### Agustin Espinoza | Version 1.0
