SET @TYPE = (SELECT `isys_tts_type__id` FROM `isys_tts_type` WHERE `isys_tts_type__const` = "C__TTS__REQUEST_TRACKER");

INSERT INTO
    `isys_tts_config`
SET
    `isys_tts_config__isys_tts_type__id` = @TYPE,
    `isys_tts_config__active` = '1',
    `isys_tts_config__service_url` = 'http://%HOST%/rt',
    `isys_tts_config__user` = '%USERNAME%',
    `isys_tts_config__pass` = '%PASSWORD%';
