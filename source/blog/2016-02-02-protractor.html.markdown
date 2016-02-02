---
title: Angular Protractor e2e Testing
date: 2016-02-02 19:21 UTC
tags:
---
Helpers, matchers and fun stuff for protractor e2e testing with Angular.

READMORE

## Run one spec only

By default `protractor protractorConfig.js` will run all the specs. Run just one:
`protractor protractorConfig.js --specs path/to/mySpec.js.` Use `iit` or `xit` instead
of it to run only one or skip a test in a file (newer versions may be `fit`
    instead for `focus`).

## Test helpers

If there is common behavior in `beforeEach` or `afterEach` blocks, refactor it into
a helper:

```javascript
module.exports = {
  login: function() {
    emailInput = element(by.model('signin.email'));
    passwordInput = element(by.model('signin.password'));
    submitButton = element(by.name('SigninButton'));

    browser.get('/#signin');
    emailInput.sendKeys('test@test.com');
    passwordInput.sendKeys('password');
    submitButton.click();
  }
}
```

Then use it in some other spec like this (the relevant part is in the beforeEach):

```javascript
var helper = require('../helpers/signinHelper')

describe('Adding friends', function(){

  beforeEach(function(){
    helper.login();
  });

  it('users can request any user to be their friend', function(){
    //do something
    expect(something).toBe('working');
  });
});
```

Be sure that the helpers are added to exclude in `protractorConfig.js` or
else they will be run as if they were regular specs.

Unfortunately, the selenium instance from this test will persist for
any specs run before or after it. This means that sessions/any cookie data
will still be around. It could be managed with a logout helper, but you can
just clear cookies like this:

```javascript
afterEach(function(){
  browser.manage().deleteAllCookies();
});
```

## Matchers

```javascript
// find by angular binding
var emailInput = element(by.model('signin.email'));

// find by element name
// this is far easier than getting css matchers to find the right element
var submitButton = element(by.name('SigninButton'));

// find by css
var bluePill = element(by.css('.blue-pill'));

// NOTE!
// multiple css classes need to be seperated by `.` to work
// ie:
var icon = element(by.css('.fa.fa-newspaper-o.fa-3x'));

// this will always fail:
var icon = element(by.css('.fa fa-newspaper-o fa-3x'));
```

## Get an array of bindings from ng-repeat

This is very useful when adding a new item to some scope and
you need to check that it is contained in ng-repeat:

```html

<li ng-repeat='user in users'>{{user.username}} </li>

```

Protractor has an easy method to get the repeater, but that only
returns an array of promises. Use map to get an array of values:

```javascript

var users = element.all(by.repeater('user in users')
            .column('user.username'))
            .map(function(element){
              return element.getText();
            });

//then use it in a matcher

expect(users).toContain('someUsername');

```

You cannot use sendKeys with OSX keys like command in order to copy/paste/delete
text in Selenium.  Instead, use javascript to clear:

```javascript

var newTitle = 'edited title';

var titleInput = element(by.name('edit-title'));

titleInput.clear();

titleInput.sendKeys(newTitle);

```

When clicking elements within a repeater, be as specific as possible to
avoid weird behavior:

```javascript
// this will act strange
// who knows what it actually clicks on

var link = element.all(by.repeater('item in stuff')).first();
link.click();

// better, more specific

var link = element.all(by.repeater('item in things')
           .column('item.name'))
           .first();

link.click();

```

When working with `ng-show` or `ng-if`, use
`expect(element.isDisplayed()).toBe(false)` instead of
`expect(element.isPresent()).toBe(false)` because the latter returns `true`
if the element is present on the template, even when the element is NOT displayed!

If the initial selenium load is so slow that a spec fails due to
`timeout: A Jasmine spec timed out`, then give it more time by adding
`jasmineNodeOpts: {defaultTimeoutInterval: timeout_in_millis}` to
`protractorConfig.js`.

Don't use locators with callbacks when their elements are not present on the
screen. Best practices say to put your page elements in one place, at the start
of the test, to maintain readability.

However, be careful using locators with callbacks:

```javascript
var firstPending = pendingList.first()
                   .then(function(elem) {
                     return elem.element(by.binding('user.username')).getText()
                   });
```

If this block is called when `pendingList` is not on the screen, it will
throw an error in the test. To fix, only call when the element is on the
screen OR refactor to avoid the callback:

```javascript
var firstPending = element.all(by.repeater('user in activeUsers')
                   .column('user.username')).first();

// later in the test

firstPending.getText();
```

## Working with select forms

Use `element(by.cssContainingText('option', '1test')).click();` where `1test`
is the value to select.


