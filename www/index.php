<!DOCTYPE html>

<?php

    $host = $_SERVER['SERVER_NAME'];
    $port = $_SERVER['SERVER_PORT'];
    $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS']) ? 'https' : 'http';
    $title = 'smartITSM Demo System';
    $website = 'http://www.smartitsm.org/';
    $module_dir = '/opt/smartitsm/www/conf.d';
    
    global $demos;
    $demos = array();
    
    // No modules installed?
    if (is_dir($module_dir) && is_readable($module_dir)) {
        $moduleDir = new DirectoryIterator($module_dir);
        
        foreach ($moduleDir as $fileInfo) {
            if ($fileInfo->isFile() === false || $fileInfo->getExtension() !== 'php' || $fileInfo->isReadable() === false) {
                continue;
            } //if
            
            require $fileInfo->getFilename();
        } //foreach
    } //if
    
    function printCredentials ($username = null, $password = null) {
        $credentials = '';
        
        if (isset($username) || isset($password)) {
            $credentials .= '&nbsp;(Credentials: <span class="monospace">';
            
            if (isset($username) && !isset($password)) {
                $credentials .= $username;
            } else if (!isset($username) && isset($password)) {
                $credentials .= $api['password'];
            } else {
                $credentials .= $username . ':' . $password;
            } // if
            
            $credentials .= '</span>)';
        } // if credentials
        
        echo $credentials;
    } //function

?>

<html>

<head>
    <title><?= $title ?></title>
    <link href="/favicon.png" type="image/png" rel="shortcut icon">
    <link href="/style.css" type="text/css" rel="stylesheet">
</head>

<body>

<div id="main">

<header>

    <a href="<?= $website ?>"><img src="/header.png" style="height: 134px; weight: 661px;" alt="smartITSM logo" style="" /></a>

</header>

<h1><a href="<?= $website ?>"><?= $title ?></a></h1>

<section id="demos">

    <?php foreach ($demos as $demo) { ?>

    <fieldset>

        <legend><a href="<?= $demo['url'] ?>"><?= $demo['title'] ?></a></legend>

        <a href="<?= $demo['url'] ?>" class="description" title="<?= $demo['versions'] ?>">
        
            <img src="/logos/<?= $demo['logo'] ?>" alt="<?= $demo['title'] ?> logo" />

            <p><?= $demo['description'] ?></p>
        
        </a>
        
        <?php if (isset($demo['credentials'])) { ?>
        
        <h2>Credentials</h2>

        <ul class="credentials">

            <?php foreach ($demo['credentials'] as $credential => $credentials) { ?>

            <li><?= $credential ?>: <span class="monospace"><?= $credentials['username'] ?>:<?= $credentials['password'] ?></span></li>

            <?php } //foreach credentials ?>

        </ul>
        
        <?php } // if credentials ?>
        
        <?php if (isset($demo['api'])) { ?>
        
        <h2>API</h2>

        <ul>

            <?php foreach ($demo['api'] as $api) { ?>
            
            <li>
                <?= $api['type'] ?>: <span class="monospace"><?= $api['url'] ?></span>
                <?= printCredentials(@$api['username'], @$api['password']); ?>
            </li>

            <?php } //foreach API ?>
        </ul>
        
        <?php } // if API ?>

        <p class="more"><a href="<?= $demo['website'] ?>">more at smartITSM&hellip;</a></p>

    </fieldset>

    <?php } //foreach demo ?>

    <fieldset style="text-align: left;">

        <legend>Tools</legend>
        
        <h2>Administrator's toolbox</h2>

        <ul>
            <li><a href="/phpinfo.php">phpinfo</a></li>
            <li><a href="/phpldapadmin">phpLDAPAdmin</a> (Credentials: <span class="monospace">cn=admin,dc=demo,dc=smartitsm,dc=org:admin</span>)</li>
            <li><a href="/phpmyadmin">phpMyAdmin (Credentials: <span class="monospace">root:root</span>)</a></li>
        </ul>

    </fieldset>

    <fieldset>

        <legend><a href="<?= $website ?>">smartITSM</a></legend>

        <a href="<?= $website ?>" style="float: left;"><img src="/smartitsm_flower.png" alt="smartITSM flower" style="height: 250px; margin-right: 1em;" />

        <p style="text-align: left;"><span class="italic">smartITSM</span> stands for great open source tools working together to enhance the IT service management of an organization.</p>
        
        </a>

        <p class="more" styke="clear: both;"><a href="<?= $website ?>">Read more&hellip;</a></p>

    </fieldset>

</section>

<div class="clear"></div>

<footer>

    <p>Copyright &copy; <?= date('Y') ?> <a href="http://www.i-doit.com/">synetics GmbH</a></p>
    
    <ul id="contact">
    
        <li><a href="http://www.smartitsm.org/_feed/blog:entry" title="Subscribe the blog post as RSS feed."><img src="/rss_32.png" alt="RSS icon" /></a></li>
        <li><a href="https://twitter.com/opensourceitsm" title="Follow @opensourceitsm on Twitter."><img src="/twitter_32.png" alt="Twitter icon" /></a></li>
        <li><a href="https://www.youtube.com/user/smartitsm" title="Visit smartITSM on YouTube."><img src="/youtube_32.png" alt="YouTube icon" /></a></li>
        <li><a href="mailto:mail@smartitsm.org" title="Email to smartITSM."><img src="/email_32.png" alt="YouTube icon" /></a></li>
    
    </ul>

</footer>

</div>

</body>
