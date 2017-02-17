﻿#include<hgl/graph/Texture.h>

namespace hgl
{
	namespace graph
	{
        Texture::Texture(TextureBaseControl *c)													//请使用CreateTexture()来创建贴图,函数在Render.h中定义
        {
            type = c->type;
            binding_type = c->binding_type;

            texture_id=c->texture_id;

            color_format = video_format = 0;
        }

        Texture::~Texture() 
        {
            glDeleteTexture(1,&texture_id);
        }

        void Texture::GenMipmaps()
        {
            tbc->GenMipmaps();
        }

        void Texture::GetMipmapLevel(int &base_level,int &max_level)
        {
            tbc->GetMipmapLevel(base_level,max_level);
        }
	}//namespace graph

    namespace graph
    {
        class TextureBaseControl;
        class Texture1D;
        class Texture2D;

        void InitTextureBaseControl(bool use_dsa);

        bool InitTextureAPI()
        {
            if(GLEW_ARB_direct_state_access)
            {
                InitTextureBaseControl(true);
            }

            return(true);
        }
    }//namespace graph
}//namespace hgl
