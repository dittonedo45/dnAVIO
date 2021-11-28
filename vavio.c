/*XXX This Document was modified on 1634629006 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <libavformat/avio.h>
#include <libavutil/opt.h>
#include <jv.h>

static jv *main_log = 0;

static void dn_set_opts(AVDictionary ** opts, jv dict)
{
    char *key = 0, *val = 0;
    jv_object_foreach(jv_copy(dict), vkey, vval) {
	if (jv_get_kind(vval) == JV_KIND_STRING) {
	    val = (char *) jv_string_value(vval);
	    key = (char *) jv_string_value(vkey);
	    (void) av_dict_set(opts, key, val, AV_OPT_SEARCH_CHILDREN);
	}
    }
}

static void dn_jv_add(jv * ob, char *key, jv el)
{
    if (ob && jv_get_kind(*ob) == JV_KIND_OBJECT) {
	*ob = jv_object_set(*ob, jv_string(key), el);
    } else if (ob && jv_get_kind(*ob) == JV_KIND_ARRAY) {
	*ob = jv_array_append(*ob, el);
    }
}

static char *dn_jv_ans(jv o)
{
    return strdup(jv_string_value(jv_dump_string(o, 0)));
}

static void log_callback(void *opa, int t, const char *str, va_list arg)
{
    char *exp = 0;
    vasprintf(&exp, str, arg);
    {
	jv data = jv_object();
	dn_jv_add(&data, "type", jv_number(t));
	dn_jv_add(&data, "issue", jv_string(exp));
	dn_jv_add((jv *) main_log, NULL, data);
    }
    free(exp);
}

char *avio_url(char *url)
{
    AVIOContext *avio = 0;
    AVDictionary *opts = 0;
    jv ans = jv_object();
    jv log = jv_array();
    jv mi_info = jv_object();

    int ret = 0;
    char *op = 0;
    char *rul = 0;

    if (!url || !strlen(url)) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error", jv_string("url is empty"));
	dn_jv_add(&ans, "contents", jv_array());
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }

    jv obj = jv_parse(url);

    if (jv_get_kind(obj) != JV_KIND_OBJECT) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error",
		  jv_string("The input Json is not properly structured"));
	dn_jv_add(&ans, "contents", jv_array());
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }

    if (jv_object_has(jv_copy(obj), jv_string("url"))) {
	jv t = jv_object_get(jv_copy(obj), jv_string("url"));
	if (jv_get_kind(t) == JV_KIND_STRING) {
	    rul = strdup((char *) jv_string_value(t));
	}
    }

    if (!rul || !strlen(rul)) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error", jv_string("url is empty"));
	dn_jv_add(&ans, "contents", jv_array());
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }

    if (jv_object_has(jv_copy(obj), jv_string("options"))) {
	jv t = jv_object_get(jv_copy(obj), jv_string("options"));
	if (jv_get_kind(t) == JV_KIND_OBJECT) {
	    dn_set_opts(&opts, t);
	}
    }

    main_log = &log;
    av_log_set_callback(log_callback);

    ret = avio_open2(&avio, rul, AVIO_FLAG_READ, NULL, &opts);

    if (ret < 0) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error", jv_string(av_err2str(ret)));
	dn_jv_add(&ans, "contents", jv_array());
	dn_jv_add(&ans, "logs", log);
	avio_close(avio);
	return dn_jv_ans(ans);
    }

    char *buf = malloc(1);
    int i = 0;

    while (1) {
	char bbuf[1054];
	ret = avio_read(avio, bbuf, sizeof(bbuf));
	if (ret == AVERROR_EOF)
	    break;
	else if (ret <= 0)
	    continue;

	buf = realloc(buf, (i + ret + 1) * sizeof(char));
	strncpy(buf + i, bbuf, ret);
	i += ret;
    }

    avio_close(avio);

    if (i == 0) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error", jv_string("no data received"));
	dn_jv_add(&ans, "contents", jv_array());
	dn_jv_add(&ans, "logs", log);
	free(buf);
	return 0;
    }

    buf[i] = 0;
    {
	jv cnts = jv_array();
	char *p = buf;

	while (p && *p) {
	    char *t = strchr(p, '\n');
	    if (t) {
		dn_jv_add(&cnts, 0, jv_string_fmt("%.*s", t - p, p));
	    } else {
		dn_jv_add(&cnts, 0, jv_string_fmt("%s", p));
		break;
	    }
	    p = t + 1;
	}

	free(buf);
	dn_jv_add(&ans, "valid", jv_true());
	dn_jv_add(&ans, "error", jv_null());
	dn_jv_add(&ans, "contents", cnts);
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }
}

char *avio_url_write(char *url)
{
    AVIOContext *avio = 0;
    AVDictionary *opts = 0;
    jv ans = jv_object();
    jv mi_info = jv_object();
    jv log = jv_array();
    jv contents = jv_null();

    int ret = 0;
    char *op = 0;
    char *rul = 0;

    if (!url || !strlen(url)) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error", jv_string("url is empty"));
	dn_jv_add(&ans, "written", jv_number(0));
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }

    jv obj = jv_parse(url);

    if (jv_get_kind(obj) != JV_KIND_OBJECT) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error",
		  jv_string("The input Json is not properly structured"));
	dn_jv_add(&ans, "written", jv_number(0));
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }

    if (jv_object_has(jv_copy(obj), jv_string("url"))) {
	jv t = jv_object_get(jv_copy(obj), jv_string("url"));
	if (jv_get_kind(t) == JV_KIND_STRING) {
	    rul = strdup((char *) jv_string_value(t));
	}
    }

    if (!rul || !strlen(rul)) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error", jv_string("url is empty"));
	dn_jv_add(&ans, "written", jv_number(0));
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }

    if (jv_object_has(jv_copy(obj), jv_string("options"))) {
	jv t = jv_object_get(jv_copy(obj), jv_string("options"));
	if (jv_get_kind(t) == JV_KIND_OBJECT) {
	    dn_set_opts(&opts, t);
	}
    }

    if (jv_object_has(jv_copy(obj), jv_string("contents"))) {
	contents = jv_object_get(jv_copy(obj), jv_string("contents"));
    }

    if (jv_get_kind(contents) != JV_KIND_ARRAY) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error",
		  jv_string("contents are not in array form."));
	dn_jv_add(&ans, "written", jv_number(0));
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }

    if (jv_array_length(jv_copy(contents)) == 0) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error", jv_string("contents array is empty"));
	dn_jv_add(&ans, "written", jv_number(0));
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }
    main_log = &log;
    av_log_set_level(AV_LOG_VERBOSE | AV_LOG_DEBUG);
    av_log_set_callback(log_callback);
    ret = avio_open2(&avio, rul, AVIO_FLAG_WRITE, NULL, &opts);

    if (ret < 0) {
	dn_jv_add(&ans, "valid", jv_false());
	dn_jv_add(&ans, "error", jv_string(av_err2str(ret)));
	dn_jv_add(&ans, "written", jv_number(0));
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }

    int chunks_written = 0;
    jv_array_foreach(jv_copy(contents), iter_i, vall) {
	char *buf = 0;
	asprintf(&buf, "%s\n", jv_string_value(vall));
	int r = 0;
	avio_write(avio, buf, (r = strlen(buf)));
	chunks_written += r;
	free(buf);
    }

    {
	avio_flush(avio);
	avio_close(avio);
	dn_jv_add(&ans, "valid", jv_true());
	dn_jv_add(&ans, "error", jv_null());
	dn_jv_add(&ans, "written", jv_number(chunks_written));
	dn_jv_add(&ans, "logs", log);
	return dn_jv_ans(ans);
    }
}

// -> 1635695167
// -> 1636378177
// -> 1636378248
// -> 1636378276
// -> 1636378308
// -> 1636378323
// -> 1636378341
// -> 1636378366
// -> 1636378466
// -> 1636378476
// -> 1636378507
// -> 1636378605
// -> 1636378635
// -> 1636520391
// -> 1636520412
// -> 1636520505
