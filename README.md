# Element build
> Helps you build and your elementary os apps on travis!

> Forked from travis.debian.net to fit elementary os needs.

## Installation

1. Add travis integration to your github repository.
2. Create *.travis.yml* file with the following content **👇**.

    ```yaml
        sudo: required
        language: generic

        services:
        - docker

        script:
        - wget -O- https://raw.githubusercontent.com/harisvsulaiman/element-build/master/script.sh | sh -

        branches:
        except:
            - /^debian\/\d/
    ```
3. Push code to your Repository to build your app on travis.
