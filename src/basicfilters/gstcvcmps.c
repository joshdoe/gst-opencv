/*
 * GStreamer
 * Copyright (C) 2010 Thiago Santos <thiago.sousa.santos@collabora.co.uk>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Alternatively, the contents of this file may be used under the
 * GNU Lesser General Public License Version 2.1 (the "LGPL"), in
 * which case the following provisions apply instead of the ones
 * mentioned above:
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gst/gst.h>
#include <gst/video/video.h>

#include "gstopencvutils.h"
#include "gstcvcmps.h"

GST_DEBUG_CATEGORY_STATIC (gst_cv_cmps_debug);
#define GST_CAT_DEFAULT gst_cv_cmps_debug

/* Filter signals and args */
enum
{
  /* FILL ME */
  LAST_SIGNAL
};
enum
{
  PROP_0,
  PROP_SCALAR,
  PROP_COMPARISON_OP
};

#define GST_TYPE_CV_COMPARISON_OP (gst_cv_comparison_op_get_type ())
static GType
gst_cv_comparison_op_get_type (void)
{
  static GType cv_comparison_op_type = 0;

  static const GEnumValue comparison_ops[] = {
    {CV_CMP_EQ, "src 'equal to' value (default)", "equal"},
    {CV_CMP_GT, "src 'greater than' value", "greater"},
    {CV_CMP_GE, "src 'greater than or equal to' value", "greatereq"},
    {CV_CMP_LT, "src 'less than' value", "less"},
    {CV_CMP_LE, "src 'less than or equal to' value", "lesseq"},
    {CV_CMP_NE, "src 'not equal to' value", "notequal"},
    {0, NULL, NULL},
  };

  if (!cv_comparison_op_type) {
    cv_comparison_op_type =
      g_enum_register_static ("GstCvComparisonOpType", comparison_ops);
  }
  return cv_comparison_op_type;
}

#define DEFAULT_COMPARISON_OP CV_CMP_EQ
#define DEFAULT_SCALAR 0.0

GST_BOILERPLATE (GstCvCmpS, gst_cv_cmps, GstOpencvBaseTransform,
    GST_TYPE_OPENCV_BASE_TRANSFORM);

static void gst_cv_cmps_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec);
static void gst_cv_cmps_get_property (GObject * object, guint prop_id,
    GValue * value, GParamSpec * pspec);

static GstFlowReturn gst_cv_cmps_transform (GstOpencvBaseTransform * filter,
    GstBuffer * buf, IplImage * img, GstBuffer * outbuf, IplImage * outimg);

/* Clean up */
static void
gst_cv_cmps_finalize (GObject * obj)
{
  G_OBJECT_CLASS (parent_class)->finalize (obj);
}

/* GObject vmethod implementations */

static void
gst_cv_cmps_base_init (gpointer gclass)
{
  GstElementClass *element_class = GST_ELEMENT_CLASS (gclass);
  GstCaps *caps;
  GstPadTemplate *templ;

  /* add sink and source pad templates */
  caps = gst_opencv_caps_from_cv_image_type (CV_8UC1);
  gst_caps_append (caps, gst_opencv_caps_from_cv_image_type (CV_8UC3));
  gst_caps_append (caps, gst_opencv_caps_from_cv_image_type (CV_8UC4));
  gst_caps_append (caps, gst_opencv_caps_from_cv_image_type (CV_16UC1));
  templ = gst_pad_template_new ("sink", GST_PAD_SINK, GST_PAD_ALWAYS, caps);
  gst_element_class_add_pad_template (element_class, templ);

  caps = gst_opencv_caps_from_cv_image_type (CV_8UC1);
  templ = gst_pad_template_new ("src", GST_PAD_SRC, GST_PAD_ALWAYS, caps);
  gst_element_class_add_pad_template (element_class, templ);

  gst_element_class_set_details_simple (element_class,
      "cvcmps",
      "Transform/Effect/Video",
      "Applies cvCmpS OpenCV function to the image",
      "Thiago Santos<thiago.sousa.santos@collabora.co.uk>");
}

/* initialize the cvcmps's class */
static void
gst_cv_cmps_class_init (GstCvCmpSClass * klass)
{
  GObjectClass *gobject_class;
  GstBaseTransformClass *gstbasetransform_class;
  GstOpencvBaseTransformClass *gstopencvbasefilter_class;
  GstElementClass *gstelement_class;

  gobject_class = (GObjectClass *) klass;
  gstelement_class = (GstElementClass *) klass;
  gstbasetransform_class = (GstBaseTransformClass *) klass;
  gstopencvbasefilter_class = (GstOpencvBaseTransformClass *) klass;

  parent_class = g_type_class_peek_parent (klass);

  gobject_class->finalize = GST_DEBUG_FUNCPTR (gst_cv_cmps_finalize);
  gobject_class->set_property = gst_cv_cmps_set_property;
  gobject_class->get_property = gst_cv_cmps_get_property;

  gstopencvbasefilter_class->cv_trans_func = gst_cv_cmps_transform;

  g_object_class_install_property (gobject_class, PROP_SCALAR,
      g_param_spec_double ("scalar",
          "scalar",
          "Scalar to and with image", -G_MAXDOUBLE, G_MAXDOUBLE, DEFAULT_SCALAR,
          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS)
      );

  g_object_class_install_property (gobject_class, PROP_COMPARISON_OP,
    g_param_spec_enum ("cmp-op",
        "cmp-op",
        "Comparison operator",
        GST_TYPE_CV_COMPARISON_OP,
        DEFAULT_COMPARISON_OP, G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS)
    );
}

static void
gst_cv_cmps_init (GstCvCmpS * filter, GstCvCmpSClass * gclass)
{
  filter->scalar = DEFAULT_SCALAR;
  filter->cmpOp = DEFAULT_COMPARISON_OP;

  gst_base_transform_set_in_place (GST_BASE_TRANSFORM (filter), FALSE);
}

static void
gst_cv_cmps_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec)
{
  GstCvCmpS *filter = GST_CV_CMPS (object);

  switch (prop_id) {
    case PROP_SCALAR:
      filter->scalar = g_value_get_double (value);
      break;
    case PROP_COMPARISON_OP:
      filter->cmpOp = g_value_get_enum (value);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
}

static void
gst_cv_cmps_get_property (GObject * object, guint prop_id,
    GValue * value, GParamSpec * pspec)
{
  GstCvCmpS *filter = GST_CV_CMPS (object);

  switch (prop_id) {
    case PROP_SCALAR:
      g_value_set_double (value, filter->scalar);
      break;
    case PROP_COMPARISON_OP:
      g_value_set_enum (value, filter->cmpOp);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
}

static GstFlowReturn
gst_cv_cmps_transform (GstOpencvBaseTransform * base, GstBuffer * buf,
    IplImage * img, GstBuffer * outbuf, IplImage * outimg)
{
  GstCvCmpS *filter = GST_CV_CMPS (base);

  cvCmpS (img, filter->scalar, outimg, filter->cmpOp);

  return GST_FLOW_OK;
}

gboolean
gst_cv_cmps_plugin_init (GstPlugin * plugin)
{
  GST_DEBUG_CATEGORY_INIT (gst_cv_cmps_debug, "cvcmps", 0, "cvcmps");

  return gst_element_register (plugin, "cvcmps", GST_RANK_NONE,
      GST_TYPE_CV_CMPS);
}
