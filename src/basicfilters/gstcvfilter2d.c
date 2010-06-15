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

#include "gstcvfilter2d.h"

GST_DEBUG_CATEGORY_STATIC (gst_cv_filter2d_debug);
#define GST_CAT_DEFAULT gst_cv_filter2d_debug

/* TODO: remove static pad templates and load in class_init, then add 
 * transform_caps function as size and number of channels must match */
static GstStaticPadTemplate sink_factory = GST_STATIC_PAD_TEMPLATE ("sink",
    GST_PAD_SINK,
    GST_PAD_ALWAYS,
    GST_STATIC_CAPS (GST_VIDEO_CAPS_GRAY16("1234"))
    );

static GstStaticPadTemplate src_factory = GST_STATIC_PAD_TEMPLATE ("src",
    GST_PAD_SRC,
    GST_PAD_ALWAYS,
    GST_STATIC_CAPS (GST_VIDEO_CAPS_GRAY16("1234"))
    );

/* Filter signals and args */
enum
{
  /* FILL ME */
  LAST_SIGNAL
};
enum
{
  PROP_0,
  PROP_HORIZ_KERNEL,
  PROP_VERT_KERNEL,
  PROP_ANCHOR
};

#define DEFAULT_KERNEL_SIZE 13
#define DEFAULT_HORIZ_KERNEL {0.00357326, 0.00586348, 0.0131965, 0.0510412, 0.122453, 0.192187, 0.22337, 0.192187, 0.122453, 0.0510412, 0.0131965, 0.00586348, 0.00357326}
#define DEFAULT_VERT_KERNEL DEFAULT_HORIZ_KERNEL
#define DEFAULT_ANCHOR {-1, -1}

GST_BOILERPLATE (GstCvFilter2D, gst_cv_filter2d, GstOpencvBaseTransform,
    GST_TYPE_OPENCV_BASE_TRANSFORM);

static void gst_cv_filter2d_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec);
static void gst_cv_filter2d_get_property (GObject * object, guint prop_id,
    GValue * value, GParamSpec * pspec);

static GstCaps *gst_cv_filter2d_transform_caps (GstBaseTransform * trans,
    GstPadDirection dir, GstCaps * caps);

static GstFlowReturn gst_cv_filter2d_cv_transform (GstOpencvBaseTransform * filter,
    GstBuffer * buf, IplImage * img, GstBuffer * outbuf, IplImage * outimg);
static GstFlowReturn gst_cv_filter2d_cv_transform_ip (
    GstOpencvBaseTransform * transform, GstBuffer * buffer, IplImage * img);

static void gst_cv_filter2d_update_horiz_kernel (GstCvFilter2D * filter,
    GValueArray * va);
static void gst_cv_filter2d_update_vert_kernel (GstCvFilter2D * filter,
    GValueArray * va);

/* Clean up */
static void
gst_cv_filter2d_finalize (GObject * obj)
{
  GstCvFilter2D * filter = GST_CV_FILTER2D (obj);

  if (filter->horiz_kernel_va)
    g_value_array_free (filter->horiz_kernel_va);
  filter->horiz_kernel_va = NULL;

  if (filter->vert_kernel_va)
    g_value_array_free (filter->vert_kernel_va);
  filter->vert_kernel_va = NULL;

  G_OBJECT_CLASS (parent_class)->finalize (obj);
}

/* GObject vmethod implementations */

static void
gst_cv_filter2d_base_init (gpointer gclass)
{
  GstElementClass *element_class = GST_ELEMENT_CLASS (gclass);

  gst_element_class_add_pad_template (element_class,
      gst_static_pad_template_get (&src_factory));
  gst_element_class_add_pad_template (element_class,
      gst_static_pad_template_get (&sink_factory));

  gst_element_class_set_details_simple (element_class,
      "cvfilter2d",
      "Transform/Effect/Video",
      "Applies cvFilter2D OpenCV function to the image",
      "Thiago Santos<thiago.sousa.santos@collabora.co.uk>");
}

/* initialize the cvfilter2d's class */
static void
gst_cv_filter2d_class_init (GstCvFilter2DClass * klass)
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

  gobject_class->finalize = GST_DEBUG_FUNCPTR (gst_cv_filter2d_finalize);
  gobject_class->set_property = gst_cv_filter2d_set_property;
  gobject_class->get_property = gst_cv_filter2d_get_property;

  gstopencvbasefilter_class->cv_trans_func = gst_cv_filter2d_cv_transform;
  gstopencvbasefilter_class->cv_trans_ip_func = gst_cv_filter2d_cv_transform_ip;

  g_object_class_install_property (gobject_class, PROP_HORIZ_KERNEL,
      g_param_spec_value_array ("horiz-kernel", "Horizontal Filter Kernel",
          "Horizontal Filter kernel for the linear filter",
          g_param_spec_double ("Element", "Filter Kernel Element",
              "Element of the filter kernel", -G_MAXDOUBLE, G_MAXDOUBLE, 0.0,
              G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS),
          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS));
  g_object_class_install_property (gobject_class, PROP_VERT_KERNEL,
      g_param_spec_value_array ("vert-kernel", "Vertical Filter Kernel",
          "Vertical Filter kernel for the linear filter",
          g_param_spec_double ("Element", "Filter Kernel Element",
              "Element of the filter kernel", -G_MAXDOUBLE, G_MAXDOUBLE, 0.0,
              G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS),
          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS));
  /* TODO add anchor property */
}

static void
gst_cv_filter2d_init (GstCvFilter2D * filter, GstCvFilter2DClass * gclass)
{
  GValue v = { 0, };
  GValueArray * va;
  gint i;
  const gdouble horz[] = DEFAULT_HORIZ_KERNEL;
  const gdouble vert[] = DEFAULT_VERT_KERNEL;

  GST_LOG_OBJECT (filter, "Initializing");

  filter->horiz_kernel_va = NULL;
  filter->vert_kernel_va = NULL;
  filter->horiz_kernel = NULL;
  filter->vert_kernel = NULL;

  va = g_value_array_new (DEFAULT_KERNEL_SIZE);
  g_value_init (&v, G_TYPE_DOUBLE);
  for (i = 0; i < DEFAULT_KERNEL_SIZE; i++) {
    g_value_set_double (&v, horz[i]);
    g_value_array_append (va, &v);
  }
  g_value_unset (&v);
  gst_cv_filter2d_update_horiz_kernel (filter, g_value_array_copy (va));
  g_value_array_free (va);

  va = g_value_array_new (DEFAULT_KERNEL_SIZE);
  g_value_init (&v, G_TYPE_DOUBLE);
  for (i = 0; i < DEFAULT_KERNEL_SIZE; i++) {
    g_value_set_double (&v, horz[i]);
    g_value_array_append (va, &v);
  }
  g_value_unset (&v);
  gst_cv_filter2d_update_vert_kernel (filter, g_value_array_copy (va));
  g_value_array_free (va);


  filter->anchor.x = -1;
  filter->anchor.y = -1;

  gst_base_transform_set_in_place (GST_BASE_TRANSFORM (filter), FALSE);
}

static GstCaps *
gst_cv_filter2d_transform_caps (GstBaseTransform * trans, GstPadDirection dir,
    GstCaps * caps)
{
  GstCaps *output = NULL;
  GstStructure *structure;
  guint i;

  output = gst_caps_copy (caps);

  /* we accept anything from the template caps for either side */
  switch (dir) {
    case GST_PAD_SINK:
      GST_DEBUG_OBJECT (caps, "transforming sink caps to src caps");
      for (i = 0; i < gst_caps_get_size (output); i++) {
        structure = gst_caps_get_structure (output, i);
        gst_structure_set (structure,
            "depth", G_TYPE_INT, 16,
            "bpp", G_TYPE_INT, 16, "endianness", G_TYPE_INT, 1234, NULL);
      }
      break;
    case GST_PAD_SRC:
      GST_DEBUG_OBJECT (caps, "transforming src caps to sink caps");
      for (i = 0; i < gst_caps_get_size (output); i++) {
        structure = gst_caps_get_structure (output, i);
        gst_structure_set (structure,
            "depth", G_TYPE_INT, 8, "bpp", G_TYPE_INT, 8, NULL);
        gst_structure_remove_field (structure, "endianness");
      }
      break;
    default:
      gst_caps_unref (output);
      output = NULL;
      g_assert_not_reached ();
      break;
  }

  return output;
}

static void
gst_cv_filter2d_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec)
{
  GstCvFilter2D *filter = GST_CV_FILTER2D (object);

  switch (prop_id) {
    case PROP_HORIZ_KERNEL:
      gst_cv_filter2d_update_horiz_kernel (filter, g_value_dup_boxed (value));
      break;
    case PROP_VERT_KERNEL:
      gst_cv_filter2d_update_vert_kernel (filter, g_value_dup_boxed (value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
}

static void
gst_cv_filter2d_get_property (GObject * object, guint prop_id,
    GValue * value, GParamSpec * pspec)
{
  GstCvFilter2D *filter = GST_CV_FILTER2D (object);

  switch (prop_id) {
    case PROP_HORIZ_KERNEL:
      g_value_set_boxed (value, filter->horiz_kernel_va);
      break;
    case PROP_VERT_KERNEL:
      g_value_set_boxed (value, filter->vert_kernel_va);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
}

static GstFlowReturn
gst_cv_filter2d_cv_transform (GstOpencvBaseTransform * base, GstBuffer * buf,
    IplImage * img, GstBuffer * outbuf, IplImage * outimg)
{
  GstCvFilter2D *filter = GST_CV_FILTER2D (base);

  cvFilter2D (img, outimg, filter->horiz_kernel, filter->anchor);
  cvFilter2D (outimg, outimg, filter->vert_kernel, filter->anchor);

  return GST_FLOW_OK;
}



static GstFlowReturn gst_cv_filter2d_cv_transform_ip (
    GstOpencvBaseTransform * transform, GstBuffer * buffer, IplImage * img)
{
  GstCvFilter2D *filter = GST_CV_FILTER2D (transform);


  cvFilter2D (img, img, filter->horiz_kernel, filter->anchor);
  cvFilter2D (img, img, filter->vert_kernel, filter->anchor);

  return GST_FLOW_OK;
}

gboolean
gst_cv_filter2d_plugin_init (GstPlugin * plugin)
{
  GST_DEBUG_CATEGORY_INIT (gst_cv_filter2d_debug, "cvfilter2d", 0, "cvfilter2d");

  return gst_element_register (plugin, "cvfilter2d", GST_RANK_NONE,
      GST_TYPE_CV_FILTER2D);
}

static void
gst_cv_filter2d_update_horiz_kernel (GstCvFilter2D * filter, GValueArray * va)
{
  guint i;

  GST_LOG ("Updating horizontal kernel");

  if (va) {
    if (filter->horiz_kernel_va)
      g_value_array_free (filter->horiz_kernel_va);

    filter->horiz_kernel_va = va;
  }
  
  if (filter->horiz_kernel) {
    cvReleaseMat (&filter->horiz_kernel);
  }
  filter->horiz_kernel = cvCreateMat (1, filter->horiz_kernel_va->n_values, CV_64F);
  GST_LOG ("Horizontal kernel has %d elements", filter->horiz_kernel_va->n_values);
  for (i = 0; i < filter->horiz_kernel_va->n_values; i++) {
    GValue *v = g_value_array_get_nth (filter->horiz_kernel_va, i);
    GST_LOG ("%f", g_value_get_double (v));
    cvSetReal2D (filter->horiz_kernel, 0, i, g_value_get_double (v));
  }
}

static void
gst_cv_filter2d_update_vert_kernel (GstCvFilter2D * filter, GValueArray * va)
{
  guint i;

  GST_LOG ("Updating vertical kernel");

  if (va) {
    if (filter->vert_kernel_va)
      g_value_array_free (filter->vert_kernel_va);

    filter->vert_kernel_va = va;
  }

  if (filter->vert_kernel) {
    cvReleaseMat (&filter->vert_kernel);
  }
  filter->vert_kernel = cvCreateMat (filter->vert_kernel_va->n_values, 1, CV_64F);

  for (i = 0; i < filter->vert_kernel_va->n_values; i++) {
    GValue *v = g_value_array_get_nth (filter->vert_kernel_va, i);
    GST_LOG ("%f", g_value_get_double (v));
    cvSetReal2D (filter->vert_kernel, i, 0, g_value_get_double (v));
  }
}